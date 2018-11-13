'''
Created on Apr 30, 2016

@author: adrianhumphrey
'''
import sys
from boto.dynamodb.condition import NULL
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

gs_conn = connect_gs(gs_access_key_id='', gs_secret_access_key='+PChgHA+0zHMpuZoZS2l4')
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
            """if the user is not in the datastore then it creates a new User, defined in models.py
            Then main.USER_PARENT_KEY is what every user has, it allows the datastore to group all the User objects into to place"""
            
            """This will get everything in their email from the start of their email until the @ symbol"""
            s = request.email
            number = s.index("@")
            email = s[0:number]
            print email
             
             
            """this will create a bucket for the user and assign it to that person will a time stamp"""
            now = time.time()
            first = request.first_name
            age = request.age
             
            """This will change the users name and email to lower case if they input any uppercase lettes"""
            first = first.lower()
            email = email.lower()
            
            USER_BUCKET = '%s-%d-%s-%d' % (first, age, email, now)

         
            my_user = User(parent=main.USER_PARENT_KEY, 
                           first_name=request.first_name, 
                           email=request.email,
                           user_location=request.user_location,
                           lat = request.lat,
                           lon = request.lon,
                           age=request.age,
                           distance_of_search=request.distance_of_search,
                           gender=request.gender,
                           looking_for=request.looking_for,
                           password=request.password,
                           user_bucket = USER_BUCKET,
                           likedArray = request.likedArray,
                           matchedArray = request.matchedArray,
                           skippedArray = request.skippedArray,
                           registration_token = request.registration_token,
                           age_range = request.age_range)
            
                
            if my_user.age_range == None:
                print 'the youngest that they would like to see is 28 years old'
            gs_conn.create_bucket(USER_BUCKET)
            
        
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