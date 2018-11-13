#!/usr/bin/env python
#
# Copyright 2007 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import webapp2
import sys

'''Google Python Upload'''
import transfer


sys.path.append("/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages")
from google.appengine.ext import ndb
from endpoints_proto_datastore.ndb.model import EndpointsModel

import os
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers
import json
from models import User, gs_conn


USER_PARENT_KEY = ndb.Key('Entity', 'user_root')

import tempfile
import io
import base64

import datetime
import md5
import time
import logging

import Crypto
import Crypto.Hash.SHA256 as SHA256
import Crypto.PublicKey.RSA as RSA
import Crypto.Signature.PKCS1_v1_5 as PKCS1_v1_5
import requests
import random
import binarytofile

from apiclient.discovery import build
from oauth2client import client



from twilio.rest import TwilioRestClient
import smtplib

try:
    import StringIO
except:
    print 'StringIO did not import'
    
try:
    from apiclient.http import MediaFileUpload 
except:
    print 'MediaUpload did not import'
# Send to single device.
from pyfcm import FCMNotification

try:
    from geopy.distance import vincenty
except:
    print'The geopy was not imported'
try:
    print 'Trying to import'
    import cloudstorage as gcs
except:
    print 'cloud storage was not imported'
try:
    import conf
except ImportError:
    sys.exit('Configuration module not found. You must create a conf.py file. '
           'See the example in conf.example.py.')
    
try:
    # Authorize server-to-server interactions from Google Compute Engine.
    from oauth2client.contrib import gce
except:
    print 'outh2 was not imported'
try:
    # Authorize server-to-server interactions from Google Compute Engine.
    import httplib2
except:
    print 'outh2 was not imported'
    
try:
    from io import BytesIO
except:
    print 'Io was not imported'
    
from oauth2client.service_account import ServiceAccountCredentials


# The Google Cloud Storage API endpoint. You should not need to change this.
GCS_API_ENDPOINT = 'https://storage.googleapis.com'




# Defines a method to get an access token from the credentials object.
# The access token is automatically refreshed if it has expired.
def get_access_token():
    # The scope for the OAuth2 request.
    SCOPE = 'https://www.googleapis.com/auth/devstorage.full_control'
    _credentials = ServiceAccountCredentials.from_json_keyfile_name('Final-Questor-App-670d3deae269.json', SCOPE)

    return _credentials.get_access_token().access_token


    
def read_in_chunks(file_object, chunk_size=65536):
    while True:
        data = file_object.read(chunk_size)
        if not data:
            break
        yield data
    
def convertBinaryToFile():
    print 'This is a file'


class CloudStorageURLSigner(object):
    """Contains methods for generating signed URLs for Google Cloud Storage."""

    def __init__(self, key, client_id_email, gcs_api_endpoint, expiration=None,
               session=None):
        """Creates a CloudStorageURLSigner that can be used to access signed URLs.
        Args:
          key: A PyCrypto private key.
          client_id_email: GCS service account email.
          gcs_api_endpoint: Base URL for GCS API.
          expiration: An instance of datetime.datetime containing the time when the
                      signed URL should expire.
          session: A requests.session.Session to use for issuing requests. If not
                   supplied, a new session is created.
        """
        self.key = key
        self.client_id_email = client_id_email
        self.gcs_api_endpoint = gcs_api_endpoint
    
        self.expiration = expiration or (datetime.datetime.now() +
                                         datetime.timedelta(days=1))
        self.expiration = int(time.mktime(self.expiration.timetuple()))
    
        self.session = session or requests.Session()

    def _Base64Sign(self, plaintext):
        """Signs and returns a base64-encoded SHA256 digest."""
        shahash = SHA256.new(plaintext)
        signer = PKCS1_v1_5.new(self.key)
        signature_bytes = signer.sign(shahash)
        return base64.b64encode(signature_bytes)

    def _MakeSignatureString(self, verb, path, content_md5, content_type):
        """Creates the signature string for signing according to GCS docs."""
        signature_string = ('{verb}\n'
                            '{content_md5}\n'
                            '{content_type}\n'
                            '{expiration}\n'
                            '{resource}')
        return signature_string.format(verb=verb,
                                       content_md5=content_md5,
                                       content_type=content_type,
                                       expiration=self.expiration,
                                       resource=path)
    def _MakeUrlForApp(self, verb, path, content_type='', content_md5=''):
        """Forms and returns the full signed URL to access GCS."""
        base_url = '%s%s' % (self.gcs_api_endpoint, path)
        signature_string = self._MakeSignatureString(verb, path, content_md5,
                                                     content_type)
        signature_signed = self._Base64Sign(signature_string)
    
        """replace @ with %40 - and + with %2 and == with %3D"""
        signature_signed = signature_signed.replace("+", "%2B")
        signature_signed = signature_signed.replace("/", "%2F")
        signature_signed = signature_signed.replace("=", "%3D")
        self.client_id_email = self.client_id_email.replace("@", "%40")
        
        signedURL = base_url + "?Expires=" + str(self.expiration) + "&GoogleAccessId=" + self.client_id_email + "&Signature=" + signature_signed 
        return signedURL
    
    
    def _MakeUrl(self, verb, path, content_type='', content_md5=''):
        """Forms and returns the full signed URL to access GCS."""
        base_url = '%s%s' % (self.gcs_api_endpoint, path)
        signature_string = self._MakeSignatureString(verb, path, content_md5,
                                                     content_type)
        signature_signed = self._Base64Sign(signature_string)
        query_params = {'GoogleAccessId': self.client_id_email,
                        'Expires': str(self.expiration),
                        'Signature': signature_signed}
        signedUrl = base_url + '?GoogleAccessId=' + self.client_id_email + '&Expires=' + str(self.expiration) + '&Signature=' + signature_signed
        return base_url, query_params

    def Get(self, path):
        """Performs a GET request.
        Args:
          path: The relative API path to access, e.g. '/bucket/object'.
        Returns:
          An instance of requests.Response containing the HTTP response.
        """
        base_url, query_params = self._MakeUrl('GET', path)
        return self.session.get(base_url, params=query_params)
    
    def last_byte(self, range_header):
        '''Parse tje last byte from a 'Range' Header'''
        _, _, end = range_header.partition('-')
        return int(end)
    
    def ResumablePut(self, objectName, bucketName, data, content_type):
        """Performs a resumable upload.
        Args:
          path: The relative API path to access, e.g. '/bucket/object'.
          content_type: The content type to assign to the upload.
          data: The file data to upload to the new file.
        Returns:
          An instance of requests.Response containing the HTTP response.
        """
        
        url = 'https://www.googleapis.com/upload/storage/v1/b/%s/o?uploadType=resumable&name=%s' % (bucketName, objectName)
        
        #Content Size of Video
        content_size = sys.getsizeof(data)
        print content_size
        
        headers = {}
        headers['Authorization'] = 'Bearer ' + get_access_token()
        headers['Content-Type'] = 'video/quicktime'
        headers['Content-Length'] = content_size
        headers['X-Upload-Content-Type'] = 'video/quicktime'
        response = requests.post(url, headers=headers)
        
        print response.status_code
        print response.headers
        returned_location = response.headers['location']
        print returned_location
        
        #chunk size 4Mb
        chunk_size = 5 * 1024 * 1024
        
        #Begin upload
        headers = {}
        headers['Content-Type'] = 'video/quicktime'
        headers['Content-Length'] = content_size
        content_range = 'bytes 0-%s/%s' %((chunk_size -1), str(content_size))
        headers['Content-Range'] = content_range
        status = None
        count = 1
        last_byte = ''
        next_byte = 0
        last = False
        
        
        while status != 201 or status != 200:
            if count == 1:
                chunk = data[:chunk_size]
            elif (last == True):
                chunk = data[last_byte-21:]
                print 'content-size - 1 - last_byte: %s, size of last chunk: %s' % ((content_size - 1 - last_byte), (sys.getsizeof(chunk))) 
            else:
                chunk = data[last_byte:next_byte]
            
            #Put peices of the file to destination
            print 'The number of bytes in the chunk is: %s' % sys.getsizeof(chunk)
            response = requests.put(returned_location, headers=headers, data=chunk)
            print headers
            print response.headers
            print response.content
            status = response.status_code
            if status == 308:
                #The position that it left off at
                print response.headers['range']
                last_byte = self.last_byte(response.headers['range']) #This is an int
                last_byte += 1 #Start the next upload off one byte up
                
                #Reset Content range 4Mb
                count+=1
                next_byte = last_byte + chunk_size
                content_range = 'bytes ' + str(last_byte) + '-' + str(next_byte) + '/' + str(content_size)
                print content_range
                
                #Set Content Range
                if last_byte - 1 == content_size:
                    #End of upload with 0 bytes left to send; just finalize.
                    content_range = 'bytes */%s' % content_size
                else:
                    next_byte1 = next_byte - 1
                    content_range = 'bytes %s-%s/%s' % (last_byte, next_byte1 , content_size)
                    
                headers['Content-Range'] = content_range
                
                #Set Content Length
                content_length = content_size - 1 - last_byte
                headers['Content-Length'] = content_length
                
                print 'content_range: %s' % content_length
                print 'content-length: %s' % chunk_size
                
                #If this is the last section, set range from last_byte to content size
                if next_byte > content_size:
                    print 'next_byte: %s' % next_byte
                    print 'content_size: %s' % content_size
                    last = True
                    
                    #Set the Content Range from the last_byte to the content_szie
                    content_range = 'bytes %s-%s/%s' % (last_byte, content_size - 1, content_size)
                    
                    #Set Content Range
                    headers['Content-Range'] = content_range
                    
                    #Set Content Length
                    content_length = content_size - 1 - last_byte
                    headers['Content-Length'] = content_length
                    
                    print 'content_range: %s' % content_range
                    print 'content-length: %s' % content_length
            else:
                #The status is not 308, you got an error
                print 'There was an error with upload chunk'
                print status
                return
                
        

    def Put(self, path, content_type, data):
        """Performs a PUT request.
        Args:
          path: The relative API path to access, e.g. '/bucket/object'.
          content_type: The content type to assign to the upload.
          data: The file data to upload to the new file.
        Returns:
          An instance of requests.Response containing the HTTP response.
        """
       
        headers = {}
        
        
        #If the video is over 8MB, perform a chuncked upload
        total_size = sys.getsizeof(data)
        print total_size
        if total_size > 9000000:
            print 'The video is greater than 9 mb, so perform a chunked upload'
            '''
            #Turn the data into a file like object
            bio = BytesIO(data)
            

            index = 0
            offset = 0
            
            
            #only upload this single chunk of the video
            chunk = bio.read(4*1024*1024)
            firstpart, secondpart = data[:len(data)/2], data[len(data)/2:]
            
            content_size = sys.getsizeof(firstpart)
            print 'Content size is ' + str(content_size)
            md5_digest = base64.b64encode(md5.new(firstpart).digest())
            base_url, query_params = self._MakeUrl('PUT', path, content_type,
                                               md5_digest)
            
            headers['Content-Type'] = content_type
            headers['Content-Length'] = content_size
            headers['Content-MD5'] = md5_digest
            
            j = self.session.put(base_url, params=query_params, headers=headers,
                                data=firstpart)
            
            """Second part"""
            content_size = sys.getsizeof(secondpart)
            print 'Content size is ' + str(content_size)
            md5_digest = base64.b64encode(md5.new(secondpart).digest())
            base_url, query_params = self._MakeUrl('PUT', path, content_type,
                                               md5_digest)
            
            headers['Content-Type'] = content_type
            headers['Content-Length'] = content_size
            headers['Content-MD5'] = md5_digest
            
            j = self.session.put(base_url, params=query_params, headers=headers,
                                data=secondpart)
            
            print j.status_code
            print j.content
            print j.headers'''
            
            


            

        else:
            print 'The video is less than 8MB so perform a simple upload'
            md5_digest = base64.b64encode(md5.new(data).digest())
            base_url, query_params = self._MakeUrl('PUT', path, content_type,
                                               md5_digest)
            headers['Content-Type'] = content_type
            headers['Content-Length'] = str(len(data))
            headers['Content-MD5'] = md5_digest
            return self.session.put(base_url, params=query_params, headers=headers,
                                data=data)
        
        

    def Delete(self, path):
        """Performs a DELETE request.
        Args:
          path: The relative API path to access, e.g. '/bucket/object'.
        Returns:
          An instance of requests.Response containing the HTTP response.
        """
        base_url, query_params = self._MakeUrl('DELETE', path)
        return self.session.delete(base_url, params=query_params)

def signProfileVideoUrls(user_bucket):
    profileVideosObjectnames = []
    signedUrls = []
    empty = False
    try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
    except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

    private_key = RSA.importKey(keytext)   
    signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
    print user_bucket
    """Get the initial profile video of the bucket"""
    for object in gs_conn.get_bucket(user_bucket):
            if 'Profile_Videos/' in object.name:
                objectname = object.name
                profileVideosObjectnames.append(objectname)
                if object.name == "Profile_Videos/":
                    profileVideosObjectnames.pop()
     
    """Signs all of the objects in the array, should be three max"""
    if not profileVideosObjectnames:
        print "List is empty"
        """add is empty to the user's initial video to remove them from the que"""
        empty = True
    else:
        for i in profileVideosObjectnames:  
            """Sign url then add it to the user's initial videos property"""
            file_path = '/%s/%s' % (user_bucket, i)
            r = signer._MakeUrlForApp('GET', file_path)
            
            """append it to an array"""
            signedUrls.append(r)
    
    """Add signed url to the user that was passed in"""
    j = User.query(User.user_bucket == user_bucket)
    for q in j.fetch():
        if empty == False:
            q.profile_video_urls = signedUrls
        else:
            print 'do nothing'

def makeGifarray(user_bucket):
    gifArray = []
    signedUrls = []
    
    
    try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
    except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

    private_key = RSA.importKey(keytext)   
    signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
    for i in gs_conn.get_bucket(user_bucket):
        if 'Profile_Images_For_Gif/' in i.name:
            gifArray.append(i.name)
            if i.name == "Profile_Images_For_Gif/":
                gifArray.pop()
        
    for i in gifArray:
        file_path = '/%s/%s' % (user_bucket, i)
        r = signer._MakeUrlForApp('GET', file_path) 
        signedUrls.append(r)   
        
    return signedUrls

class MainHandler(webapp2.RequestHandler):
    
    def get(self):
        self.response.write('Hello world!')
        #ast_byte = str(int(last_byte) +1)
        last_byte = '23423'
        #turn this to an int then add one then trun it back to str
        print str(int(last_byte) + 1)
       
        


class SignURLHandler(webapp2.RequestHandler):
    def get(self):
        bucketname = self.request.get('bucketname')
        objectname = self.request.get('objectname')

        try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
        except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

        private_key = RSA.importKey(keytext)   
        signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
        file_path = '/%s/%s' % (bucketname, objectname)

        r = signer._MakeUrlForApp('GET', file_path)
            
        self.response.headers['Content-Type'] = 'application/json'
        obj = {
                'signedURL': r
            }
        self.response.out.write(json.dumps(obj))

            
class ObjectList(webapp2.RequestHandler):
    def get(self):
        print 'the joke is on you'
        bucketname = self.request.get('bucketname')
        print bucketname
        count = 0
        for obj in gs_conn.get_bucket(bucketname):
            print obj.name
            self.response.headers['Content-Type'] = 'application/json'
            obj = {
                   'objectname%s' % count: obj.name
                   }
            self.response.out.write(json.dumps(obj))
            count+=1
            if count == 1:
                break
            
class GetData(webapp2.RequestHandler):
    def post(self):
        data = self.request.get('file')
        bucketname = self.request.get('bucketname')
        objectname = self.request.get('objectname')
        typeOf = self.request.get('content_type')
        sender = self.request.get('sender')
        profileVideo = self.request.get('isProfileVideo')
        gifImage = self.request.get('isGifImgae')
        file_path = ''
        j = ''
        
    
        now = time.time()
        if objectname == '':
            objectname = now

    
        try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
        except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

        private_key = RSA.importKey(keytext)   
        signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
        
        subDirectory = 'videoMesseagesFrom' + sender
        
        if profileVideo == 'true':
            file_path = '/%s/Profile_Videos/%s' % (bucketname, objectname)
            """check size of video"""
            total_size = sys.getsizeof(data)
            print total_size
            if total_size > 9000000:
                r = signer.ResumablePut(objectname, bucketname, data, typeOf)
            else:
                r = signer.Put(file_path, typeOf, data)
                
            j = signer._MakeUrlForApp('GET', file_path)
        elif gifImage == 'True':
            file_path = '/%s/Profile_Images_For_Gif/%s' % (bucketname, objectname) 
            r = signer.Put(file_path, typeOf, data)
        else:
            """TODO: set up large uploads for other people"""
            file_path = '/%s/%s/%s' % (bucketname, subDirectory, objectname)
            r = signer.Put(file_path, typeOf, data)

        if profileVideo == 'true':
            self.response.headers['Content-Type'] = 'application/json'  
            obj = {
                       'signedUrl' : j
                       } 
            self.response.out.write(json.dumps(obj))  
        else:
            self.response.headers['Content-Type'] = 'application/json'  
            obj = {
                       'signedUrl' : 'Video Success Fully uploaded'
                       } 
            self.response.out.write(json.dumps(obj))   
            
class QueryMatches(webapp2.RequestHandler):
    def get(self):
        bucketName = self.request.get('bucketName')
        matchedArray = []
        returnMatches = []
        j = User.query(User.user_bucket == bucketName)
        for q in j.fetch():
            for w in q.matchedArray:
                matchedArray.append(str(w))
    
        print matchedArray
        if len(matchedArray) == 0:
            print 'This users currently has no matches'
        else:
            print 'This users currently has matches'
            r = User.query(User.user_bucket.IN(matchedArray))
            for i in r.fetch():
                returnMatches.append(i)
         
        self.response.headers['Content-Type'] = 'application/json'  
        obj = {
                       'UserArray' : returnMatches
                       }
        if not matchedArray:
            self.response.out.write('You have not matched with anyone yet')
        else:
            for p in User.query(User.user_bucket.IN(matchedArray)).fetch():
                p.profile_gif = makeGifarray(p.user_bucket)
            self.response.out.write(json.dumps([p.to_dict() for p in User.query(User.user_bucket.IN(matchedArray)).fetch()]))
            
class Add(webapp2.RequestHandler):
    def post(self):
        bucketName = self.request.get('bucketname')

        name = self.request.get('bucketToSave')
        
        toSave = self.request.get('toSave')
        
        r = User.query(User.user_bucket == bucketName)
        
        if toSave == 'liked':
            print 'save liked person'
            
            for j in r.fetch():
                print j.first_name
                j.likedArray.append(name)
                j.put()
                
        elif toSave == 'skipped':
            print 'save skipped person'
            print bucketName
            
            for j in r.fetch():
                j.skippedArray.append(name)
                j.put()
        else:
            print 'save matched person'
            for j in r.fetch():
                j.matchedArray.append(name)
                j.put()
                
                l = User.query(User.user_bucket == j.user_bucket)
                for k in l.fetch():
                    k.matchedArray.append(bucketName)
                    k.put
            
            """Then add the liker to the liked matched array"""
            
            """Query the liked person"""
            q = User.query(User.user_bucket == name)
            for i in q.fetch():
                i.matchedArray.append(bucketName)
                i.put()
        
class QueryUnViewed(webapp2.RequestHandler):
    """This will take in a User Object, it will query all of the users, filter gender,
    only people that are not in thier likedArray or that are not in their skipped array, filter location,"""
    """This will return an array of user buckets to the app, the app will then use the endpoints and the names in that array
    to call actuall Users or what ever you need"""
    def get(self):
        """pass in location"""
        lat = self.request.get('lat')
        lon = self.request.get('lon')
        
        """Pass in gender and who they are looking for"""
        """If male and looking for females, query all of the women looking for men. Vice Versa"""
        gender = int(self.request.get('gender'))
        lookingFor = int(self.request.get('lookingFor'))
        
        """Pass in the user's age and age preference"""
        userAge = self.request.get('userAge')
        ageLow = int(self.request.get('ageLow'))
        ageHigh = int(self.request.get('ageHigh'))
        
        """Pass in the distance the user has specified, which they can change"""
        distanceOfSearch = self.request.get('distance')
        
        """pass in the users bucket so it can query themself to access their arrays"""
        userBucket = self.request.get('userBucket')
        
        """Pass in whether the user is looking for dating, friends, or both"""
        dating = 2
        if self.request.get('dating') == '':
            dating = 2
        else:
            dating = int(self.request.get('dating'))
        
        """The array of user buckets to be returned to the app"""
        unfetchedUsers = []
        
        """This will be the array of users that are already in the persons liked array and skipped arrary"""
        likedArray = []
        skippedArray = []
        matchedArray = []
        r = User.query(User.user_bucket == userBucket)
        for j in r.fetch():
            for q in j.likedArray:
                likedArray.append(q)
            for w in j.skippedArray:
                skippedArray.append(w)
            for r in j.matchedArray:
                matchedArray.append(r)
          
        
        """list containing everyone that you would skip over by adding liked and skipped"""
        mergedList = likedArray + skippedArray + matchedArray

        """Query all of the users that the user is lookingFor"""
        """If lookingFor = 0 then they are looking for males, 1 for females, 2 for both"""
        if lookingFor == 2:
            q = User.query()
        else:
            q = User.query(User.gender == lookingFor, User.looking_for == gender)
        
        """iterate through all of the matches and if the distance is lower of equal to the specified distance append them to array to be
        returned"""
        """add an age filter as well"""
        for p in q.fetch():
            """calculate the distnce between user passed in and the userfetched"""
            userLocation = (lat, lon)
                
            queriedUserLocation = (p.lat, p.lon)
            distance = vincenty(userLocation, queriedUserLocation).miles
            print distance
            print p.first_name
            
            """If both users are within each others radius"""
            if distance <= distanceOfSearch and distance <= p.distance_of_search:
                
                print p.age
                print ageHigh
                print ageLow
                if p.age <= ageHigh:
                    print 'p.age <= ageHigh'
                else:
                    print 'p.age > ageHigh'
                    
                if p.age >= ageLow:
                    print 'p.age >= p.age_low'
                else:
                    print 'p.age < p.age_low'
                    
                    
                """If both the users are looking for dating and/friends"""
                if dating == 2 or dating == p.dating or p.dating == None or p.dating == 2:    
                    
                    """If both users are with each others age range"""
                    if p.age <= ageHigh and p.age >= ageLow:
                        
                    
                        """If the user has not been liked already or skipped already"""
                        if p.user_bucket not in mergedList:
                            """Add 5 signed urls to their properties"""
                            p.profile_gif = makeGifarray(p.user_bucket)
                            
                            """add the distance to the user's distance away quality"""
                            distance = int(round(distance))
                            p.distance_away = distance
                            
                            """Sign all of the user profile video, so it makes it easy to pass in their urls when they go to their profile"""
                            signProfileVideoUrls(p.user_bucket)
                            
                            """Check if that person has like you already"""
                            if userBucket in p.likedArray:
                                """Add them to has_liked boolean property"""
                                p.liked_you = 'True'
                            else:  
                                p.liked_you ='False' 
                            """Add bucket to Array"""
                            unfetchedUsers.append(p.user_bucket)
                       
        
        print 'This is the array of people that it successfully queried'
        print unfetchedUsers
        
        print 'Check to make sure if the user has not queried themselves'
        if userBucket in unfetchedUsers:
            unfetchedUsers.remove(userBucket)
        
        self.response.headers['Content-Type'] = 'application/json'  
        obj = {
                       'UnfetchedUsers' : unfetchedUsers
                       } 
        if not unfetchedUsers:
            self.response.out.write('Sorry, there is no one in your area matching your preferences at this time')
        else:
            self.response.out.write(json.dumps([p.to_dict() for p in User.query(User.user_bucket.IN(unfetchedUsers)).fetch()])) 

class GetProfileVideoSignedURLs(webapp2.RequestHandler):    
    def get(self):
        bucketname = self.request.get('bucketname')
        signedURLS = []
        try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
        except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

        private_key = RSA.importKey(keytext)   
        signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
        
        
        for object in gs_conn.get_bucket(bucketname):
            if 'Profile_Videos/' in object.name:
                print object.name
                objectname = object.name
                """Sign url then add it to an array to be returned"""
                file_path = '/%s/%s' % (bucketname, objectname)
                r = signer._MakeUrlForApp('GET', file_path)
                signedURLS.append(r)
                if object.name == "Profile_Videos/":
                    signedURLS.pop()
                
                
        self.response.headers['Content-Type'] = 'application/json'
        obj = {
                'signedURLS': signedURLS
            }
        self.response.out.write(json.dumps(obj))
                 
class UpdateRegistrationToken(webapp2.RequestHandler):
    def post(self):
        bucketname = self.request.get('bucketname')
        registration_token = self.request.get('registrationToken')
        
        
        """Query that user"""
        r = User.query(User.user_bucket == bucketname)
        
        """Updates Registration token"""
        for j in r.fetch():
            j.registration_token = registration_token
            j.put()
        
        
class UpdateLocation(webapp2.RequestHandler):
    def post(self):
        bucketname = self.request.get('bucketname')
        lat = float(self.request.get('lat'))
        lon = float(self.request.get('lon'))
        city = self.request.get('city')
        
        print bucketname
        print lat
        print lon
        
        """Query that user"""
        r = User.query(User.user_bucket == bucketname)
        
        """Updates Registration token"""
        for j in r.fetch():
            print j.first_name
            j.lat = lat
            j.lon = lon
            j.user_location = city
            j.put()
            
            
"""Right not it is going to send a notification back to my own phone. Will change back after test"""
class Notification(webapp2.RequestHandler):
    def get(self):
        
        
        senderFirstName = self.request.get('firstName')
        toBucket = self.request.get('toBucket') 
        notification_type = self.request.get('notificationType')
        registration_id = ''
        
        print toBucket

        """Query that user"""
        r = User.query(User.user_bucket == toBucket)
        
        """Grab their current registration token"""
        for j in r.fetch():
            registration_id = j.registration_token
        
        """Initializing the notification service"""        
        push_service = FCMNotification(api_key="AIzaSyC6vzkRMzlOzDjnJwB5TDpcPY7BUQL54Xg")
        
        # Sending a notification with data message payload
        data_message = {
            "Nick" : "Mario",
            "body" : "great match!",
            "Room" : "PortugalVSDenmark"
        }
        
        # To a single device
        result = push_service.notify_single_device(registration_id=registration_id, data_message=data_message)
        
        print result 
        
        if notification_type == 'like':                    
            message_title = 'Tru'
            message_body = senderFirstName + ' has liked you!'
            print message_body
            result = push_service.notify_single_device(registration_id=registration_id, message_title=message_title, message_body=message_body)
        elif notification_type == 'match':
            message_title = 'Tru'
            message_body = 'Congratulations! You have just matched with someone! Introduce yourself!'
            result = push_service.notify_single_device(registration_id=registration_id, message_title=message_title, message_body=message_body)
        else:
            message_title = 'Tru'
            message_body = senderFirstName + ' has sent you a message!'
            result = push_service.notify_single_device(registration_id=registration_id, message_title=message_title, message_body=message_body)
            
                    
        print result
        
          
        
class LoginUser(webapp2.RequestHandler):
    def get(self):
        email = self.request.get('email')    
        password = self.request.get('password')
        
        isVerified = 'False'
        loginUser = []
        
        """Check if the email that was passed in was a email or password"""
        if len(email) == 10 and email.isdigit():
            """This is a phone number"""
            """Query that user"""
            r = User.query(User.phone_number == int(email))
            print email

        else:   
            """Query that user"""
            r = User.query(User.email == email)
            
        if r.count() == 0:
            """Return isVerified as False"""
            self.response.headers['Content-Type'] = 'application/json'
            obj = {
                        'isVerified' : isVerified
                    }
            self.response.out.write(json.dumps(obj))
            return
            
    
        
        """Check if passwords are the same"""
        for j in r.fetch():
            print j.password 
            if j.password == password:
                """Add the signed urls for thier profile videos"""
                signProfileVideoUrls(j.user_bucket)
                
                """Add the users gif profile picture url to the user logging in"""
                j.profile_gif = makeGifarray(j.user_bucket)
                
                """Add this user to an array and Return that user"""
                loginUser.append(j.user_bucket)
                
                self.response.out.write(json.dumps([p.to_dict() for p in User.query(User.user_bucket.IN(loginUser)).fetch()])) 
                return
            
            else:
                """Return isVerified as False"""
                self.response.headers['Content-Type'] = 'application/json'
                obj = {
                        'isVerified' : isVerified
                    }
                self.response.out.write(json.dumps(obj))
                return
                
            
                
        
        
class VideoMessages(webapp2.RequestHandler):
    def post(self):
        bucketname = self.request.get('bucketname')
        selfBucket = self.request.get('selfBucket')
        messageURLs = []
        objectNames = []
        try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
        except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

        private_key = RSA.importKey(keytext)   
        signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
        
        folder = 'videoMesseagesFrom' + bucketname
        for object in gs_conn.get_bucket(selfBucket):
            
            if folder in object.name:
                objectname = object.name
                """Sign url then add it to an array to be returned"""
                file_path = '/%s/%s' % (selfBucket, objectname)
                r = signer._MakeUrlForApp('GET', file_path)
                messageURLs.append(r)
                
                """Add the object name to the array"""
                objectNames.append(object.name)
                
        
        
        self.response.headers['Content-Type'] = 'application/json'
        obj = {
                'signedURLS': messageURLs,
                'objectNames' : objectNames
            }
        self.response.out.write(json.dumps(obj))
             
"""This method is called when the user refreshes the matchesview, only will return which users in their matches have sent them a video and how many"""
class VideoMessagesCheck(webapp2.RequestHandler):
    def post(self):
        bucketname = self.request.get('bucketname')
        buckets = [] 
        print bucketname
        
        for object in gs_conn.get_bucket(bucketname):
            if 'videoMesseagesFrom' in object.name:
                
                """Grab the bucket name"""
                bucketName = object.name
                number = bucketName.index("/")
                bucketName = bucketName[0:number]
                bucketName = bucketName[18:]
                
                """Add bucket to the array"""
                if bucketName not in buckets:
                    print buckets
                    print bucketName + 'is not already in this bucket'
                    buckets.append(bucketName)
            
        self.response.headers['Content-Type'] = 'application/json'
        obj = {
                'buckets': buckets
            }
        self.response.out.write(json.dumps(obj))
                
        
class DeleteVideoWatched(webapp2.RequestHandler):
    def post(self):
        selfBucket = self.request.get('selfBucket')
        objectname = self.request.get('objectname')
        
        for object in gs_conn.get_bucket(selfBucket):
                """Delete the video that was just watched"""
                if object.name == objectname:
                    object.delete()
                    
            
class GetProfileGif(webapp2.RequestHandler):    
    def get(self):
        bucketname = self.request.get('bucketname')
        signedURLS = []
        try:
            keytext = open(conf.PRIVATE_KEY_PATH, 'rb').read()
        except IOError as e:
            sys.exit('Error while reading private key: %s' % e)

        private_key = RSA.importKey(keytext)   
        signer = CloudStorageURLSigner(private_key, conf.SERVICE_ACCOUNT_EMAIL,
                                     GCS_API_ENDPOINT)
        
        
        for object in gs_conn.get_bucket(bucketname):
            if 'Profile_Images_For_Gif/' in object.name:
                objectname = object.name
                """Sign url then add it to an array to be returned"""
                file_path = '/%s/%s' % (bucketname, objectname)
                r = signer._MakeUrlForApp('GET', file_path)
                signedURLS.append(r)
                if object.name == "Profile_Images_For_Gif/":
                    signedURLS.pop()
                
                
        self.response.headers['Content-Type'] = 'application/json'
        obj = {
                'signedURLS': signedURLS
            }
        self.response.out.write(json.dumps(obj))   
    
class VerifyPhoneNumber(webapp2.RequestHandler):    
    def post(self):
        """Pass in the phone number, send back a verification code"""
        phoneNumber = self.request.get('phoneNumber')
        phoneNumber1 = '+1' + phoneNumber
        confirmationCode = ''

                                           
        
        rand = random.sample([1, 2, 3, 4, 5],  3)
        for ran in rand:
            """Append these integers to a string"""
            confirmationCode += str(ran)
        bodyMessage = 'Hello from Tru! ' + confirmationCode + ' is your verification code.'
        
        """Save the confirmation code to the user"""
        r = User.query(User.phone_number == int(phoneNumber))
        for i in r.fetch():
            i.confirmation_code = confirmationCode
            i.put()
        
    
        
        # Find these values at https://twilio.com/user/account
        account_sid = "ACccae8c7aa086a415a118fc95c9c734c2"
        auth_token = "a473f56203af094ed710ade70c8a43ab"
        client = TwilioRestClient(account_sid, auth_token)
        message = client.messages.create(to=phoneNumber1, from_="+12018028116",
                                         body=bodyMessage)

class ConfirmCode(webapp2.RequestHandler):    
    def post(self):
        """Pass in the confirmation code"""
        confirmation_code = self.request.get('code')
        phoneNumber = self.request.get('phoneNumber')
        checkConfirm = ''
        
        """Grab the user's confirmation code"""
        r = User.query(User.phone_number == int(phoneNumber))
        for i in r.fetch():
            checkConfirm = i.confirmation_code
            
        if checkConfirm == confirmation_code:
            """Send a response so the iphone can update"""
            self.response.headers['Content-Type'] = 'application/json'
            obj = {
                'Confirmed' : 'true'
            }
            self.response.out.write(json.dumps(obj))
        else:
            """Send a response so the iphone can update"""
            self.response.headers['Content-Type'] = 'application/json'
            obj = {
                'Confirmed' : 'false'
            }
            self.response.out.write(json.dumps(obj)) 
            
        """Delete their entity from data store"""
        r = User.query(User.phone_number == int(phoneNumber))
        for i in r.fetch():
            i.key.delete()     
            

class DeleteAccount(webapp2.RequestHandler):    
    def post(self):  
        userbucket = self.request.get('bucketName') 
        
        """Delete all objects in bucket"""
        for object in gs_conn.get_bucket(userbucket):
                object.delete()
                
        """Delete their bucket"""
        gs_conn.delete_bucket(userbucket) 
        
        """Delete their entity from data store"""
        r = User.query(User.user_bucket == userbucket)
        for i in r.fetch():
            i.key.delete() 
            
class GetLoggedIn(webapp2.RequestHandler):
    def get(self):
        bucket = self.request.get('bucket')    
        loginUser = []
        
        """Query that user"""
        r = User.query(User.user_bucket == bucket)
        
        """Check if passwords are the same"""
        for j in r.fetch(): 

            """Add the signed urls for thier profile videos"""
            signProfileVideoUrls(j.user_bucket)
            
            """Add the users gif profile picture url to the user logging in"""
            j.profile_gif = makeGifarray(j.user_bucket)
            
            """Add this user to an array and Return that user"""
            loginUser.append(j.user_bucket)
            
            self.response.out.write(json.dumps([p.to_dict() for p in User.query(User.user_bucket.IN(loginUser)).fetch()])) 

class Unmatch(webapp2.RequestHandler):
    def post(self):
        selfBucket = self.request.get('selfBucket')
        bucketToUnmatch = self.request.get('bucketToUnmatch')
        print selfBucket
        print bucketToUnmatch
        """Query all users"""
        r  = User.query(User.user_bucket == selfBucket)
    
        for i in r.fetch():
            print i.first_name
            if bucketToUnmatch in i.matchedArray :
                print 'bucket was found in matched array'
                print i.matchedArray
                i.matchedArray.remove(bucketToUnmatch)
                i.put()
                
class ReportUser(webapp2.RequestHandler):
    def post(self):
        msg = self.request.get('content')
        selfBucket = self.request.get('selfBucket')
        bucketName = self.request.get('bucketToReport')
        subject = 'Report User with bucket name : ' + bucketName + 'From user with bucket name: ' + selfBucket
        #sendEMail(msg, subject)
        message = subject + msg
        # Find these values at https://twilio.com/user/account
        account_sid = "ACccae8c7aa086a415a118fc95c9c734c2"
        auth_token = "a473f56203af094ed710ade70c8a43ab"
        client = TwilioRestClient(account_sid, auth_token)
        message = client.messages.create(to='+17708079716', from_="+12018028116",
                                         body=message)
       

        
app = webapp2.WSGIApplication([
    ('/', MainHandler), 
    ('/deleteAccount', DeleteAccount),
    ('/unmatch', Unmatch),
    ('/report', ReportUser),
    ('/getProfileGIF', GetProfileGif),
    ('/verifyphone', VerifyPhoneNumber),
    ('/verifyphone/confirmCode', ConfirmCode),
    ('/deleteVideo/watched', DeleteVideoWatched),
    ('/messages', VideoMessages), 
    ('/messages/check', VideoMessagesCheck), 
    ('/login', LoginUser), 
    ('/getLoggedInUser', GetLoggedIn), 
    ('/notification', Notification),
    ('/update/registrationToken', UpdateRegistrationToken),
    ('/update/location', UpdateLocation),
    ('/getProfileURLS', GetProfileVideoSignedURLs),
    ('/queryUnviewed', QueryUnViewed),
    ('/add', Add),
    ('/queryMatches', QueryMatches),
    ('/getData', GetData),
    ('/getLastObjectName', ObjectList),
    ('/signUrl', SignURLHandler)
], debug=False)