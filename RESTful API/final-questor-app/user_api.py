'''
Created on Apr 30, 2016

@author: adrianhumphrey
'''
import sys
sys.path.append("/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages")
import boto
from boto import connect_gs

import endpoints
import protorpc

import main
import time
from models import User

from google.appengine.ext import ndb
from google.appengine.api import app_identity
from google.appengine.api import images
from google.appengine.ext import blobstore
from google.appengine.ext.webapp import blobstore_handlers

import os
import shutil
import StringIO
import tempfile
import time

gs_conn = connect_gs(gs_access_key_id='GOOGOFVKAJIC5VSCR3OT', gs_secret_access_key='QMaFR9XJMkh2L5P41qQ+PChgHA+0zHMpuZoZS2l4')
GOOGLE_STORAGE = 'gs'

@endpoints.api(name="user", version="v1", description="This should be for movie quotes but it says User" )
class UserApi(protorpc.remote.Service):
    """This is the api for the movie Quotes"""
    pass
    
    
    @User.method(name="user.create", path="user/create", http_method="POST")
    def user_create(self, request):
             
        """create users as well as update the data"""
        if request.from_datastore:
            """if the user is already in the datastore, then it updates my_user will what the request object, it compares their entityKey"""
            my_user = request
        else:
            """if this is a creation by phone number, don't do all these checks"""
            if request.email is None:
                """if the user is not in the datastore then it creates a new User, defined in models.py
                Then main.USER_PARENT_KEY is what every user has, it allows the datastore to group all the User objects into to place"""

                 
                """this will create a bucket for the user and assign it to that person will a time stamp"""
                now = time.time()
    
                age = request.age
                 
                """This will change the users name and email to lower case if they input any uppercase lettes"""
                if request.first_name is not None:
                    firstNameForBucket = request.first_name
                    firstName = request.first_name
                    
                phone = request.phone_number
            
                
               
                my_user = User(parent=main.USER_PARENT_KEY, 
                               first_name=request.first_name, 
                               email=request.email,
                               user_location=request.user_location,
                               lat = request.lat,
                               lon = request.lon,
                               age_low = request.age_low,
                               age_high = request.age_high,
                               bio = request.bio,
                               age=request.age,
                               distance_of_search=request.distance_of_search,
                               gender=request.gender,
                               looking_for=request.looking_for,
                               password=request.password,
                               likedArray = request.likedArray,
                               matchedArray = request.matchedArray,
                               skippedArray = request.skippedArray,
                               registration_token = request.registration_token,
                               age_range = request.age_range,
                               phone_number = request.phone_number) 
                
                if request.first_name is not None:
                    if ' ' in firstNameForBucket:
                        print 'there is a space in the users name'
                        firstNameForBucket = firstNameForBucket.replace(" ", "")
                        firstNameForBucket = firstNameForBucket.lower()
                        print firstNameForBucket
                        
                    firstNameForBucket = firstNameForBucket.replace(" ", "")
                    firstNameForBucket = firstNameForBucket.lower()
                    USER_BUCKET = '%s-%d-%s-%d' % (firstNameForBucket, age, phone, now)
                    print USER_BUCKET
                    my_user.user_bucket = USER_BUCKET
                    gs_conn.create_bucket(USER_BUCKET)
                    print 'bucket was created'

            else:
                """if the user is not in the datastore then it creates a new User, defined in models.py
                Then main.USER_PARENT_KEY is what every user has, it allows the datastore to group all the User objects into to place"""
                
                if request.email is None:
                    """Do nothing"""
                else:
                    """This will get everything in their email from the start of their email until the @ symbol"""
                    s = request.email
                    number = s.index("@")
                    email = s[0:number]
                    if "."  in email:
                        email = email.replace(".", "")
                    print email
                 
                 
                    """this will create a bucket for the user and assign it to that person will a time stamp"""
                    now = time.time()
                    first = request.first_name
                    firstNameForBucket = request.first_name
                    print firstNameForBucket
                    
                    age = request.age
                     
                    """This will change the users name and email to lower case if they input any uppercase lettes"""

                    email = email.lower()
                    phone = request.phone_number
                    if ' ' in firstNameForBucket:
                        print 'there is a space in the users name'
                        firstNameForBucket = firstNameForBucket.replace(" ", "")
                        firstNameForBucket = firstNameForBucket.lower()
                        print firstNameForBucket
        

        
                 
                    my_user = User(parent=main.USER_PARENT_KEY, 
                                   first_name=first, 
                                   email=request.email,
                                   user_location=request.user_location,
                                   lat = request.lat,
                                   lon = request.lon,
                                   age_low = request.age_low,
                                   age_high = request.age_high,
                                   bio = request.bio,
                                   age=request.age,
                                   distance_of_search=request.distance_of_search,
                                   gender=request.gender,
                                   looking_for=request.looking_for,
                                   password=request.password,
                    
                                   likedArray = request.likedArray,
                                   matchedArray = request.matchedArray,
                                   skippedArray = request.skippedArray,
                                   registration_token = request.registration_token,
                                   age_range = request.age_range,
                                   phone_number = request.phone_number)
                    
                             
                    """If there is a first name in request"""
                    if request.first_name is not None:
                        """Remove the spaces"""
                        if ' ' in firstNameForBucket:
                            print 'there is a space in the users name'
                            firstNameForBucket = firstNameForBucket.replace(" ", "")
                            firstNameForBucket = firstNameForBucket.lower()
                            print firstNameForBucket
                        
                        firstNameForBucket = firstNameForBucket.replace(" ", "")
                        firstNameForBucket = firstNameForBucket.lower()
                        USER_BUCKET = '%s-%d-%s-%d' % (firstNameForBucket, age, email, now)
                        print USER_BUCKET
                        my_user.user_bucket = USER_BUCKET
                        gs_conn.create_bucket(USER_BUCKET)
                        print 'bucket was created'
            
        
        """This put method is what actually uploads my_user to the datastore"""
        my_user.put()
        
        return my_user
    
    @User.query_method(path="user/list", http_method="GET", name="user.list", query_fields=("limit", "user_bucket", "email", "age","gender", "order", "pageToken"))
    def user_list(self, query):
        """returns a list of all of the users"""
        
        return query
    

    
    @User.method(request_fields=("entityKey",), name="user.delete", path="user/delete/{entityKey}", http_method="DELETE")   
    def user_delete(self, request):
    
        if not request.from_datastore():
            raise endpoints.NotFoundException("User was not found")
        request.key.delete()
        
        return User() 
    

        


app = endpoints.api_server([UserApi], restricted=False)