'''
Created on Apr 30, 2016

@author: adrianhumphrey
'''

import sys
sys.path.append("/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages")

from endpoints_proto_datastore.ndb.model import EndpointsModel
from google.appengine.ext import ndb
from boto import connect_gs

gs_conn = connect_gs(gs_access_key_id='GOOGOFVKAJIC5VSCR3OT', gs_secret_access_key='QMaFR9XJMkh2L5P41qQ+PChgHA+0zHMpuZoZS2l4')
GOOGLE_STORAGE = 'gs'

    
class User(EndpointsModel):
    """This is the User that is created and shown when the user signs up and enters all of their information"""
    
    """What this message_fields_schmema does is, everything that is in quotations, is accessible, essentially public variables"""
    _message_fields_schema = ("entityKey", "first_name", "dating", "confirmation_code", "phone_number", "bio", "age_low", "age_high", "age_range", "user_location", "profile_gif", "lat", "lon", "distance_away", "age", "email", "password", "distance_of_search", "gender", "looking_for", "user_bucket", "likedArray", "skippedArray", "matchedArray", "profile_video_urls", "liked_you")
    first_name = ndb.StringProperty()
    """This is the location that the user is prompted to enter, e.g. "Atlanta" """
    user_location = ndb.StringProperty()
    """This is will hold the user's location with two different properties, lat and long"""
    lat = ndb.FloatProperty()
    lon = ndb.FloatProperty()
    age = ndb.IntegerProperty()
    email = ndb.StringProperty()
    """User will enter the distance their would like to see potential matches, and can be changed in settings"""
    distance_of_search = ndb.IntegerProperty()
    """The gender is stored as an integer to make sorting and comparisions easier, 0 for MALE, 1 for FEMALE"""
    gender = ndb.IntegerProperty()
    """0 for MALE, 1 for FEMALE, 2 for BOTH"""
    looking_for = ndb.IntegerProperty()
    password = ndb.StringProperty()
    """This property will keep the users specific bucket name that was created when they sign up"""
    user_bucket = ndb.StringProperty()
    """This is a list with only two values that contain the person preferred age range. list[0] = youngest and list[1] = oldest"""
    age_range = ndb.IntegerProperty(repeated = True)
    """This will hold the registration token of the device that the User is using to send notifications"""
    registration_token = ndb.StringProperty()
    """Whe the user queries people, it will grab their and sign all of the videos that it has in thier profile folder which is three at max"""
    profile_video_urls = ndb.StringProperty(repeated = True)
    """This property will tell the app if they liked them already, so that the pop up will be instant instead of querying it again"""
    liked_you = ndb.StringProperty()
    """This property will keep track of the distanstance the user is away from you, will not be put in datastore"""
    distance_away = ndb.IntegerProperty()
    """This property will be an array of signed urls for their profile gifs"""
    profile_gif = ndb.StringProperty(repeated = True)
    """This is one long string that will hold the user's inputed bio"""
    bio = ndb.StringProperty()
    """This will be an integer holding the age low preference"""
    age_low = ndb.IntegerProperty()
    """This will be and integer the age high prefrence"""
    age_high = ndb.IntegerProperty()
    """confirmation code to confirm phone number"""
    confirmation_code = ndb.StringProperty()
    """Stores the user's phone number if their decide to sign up with phone number"""
    phone_number = ndb.IntegerProperty()
    """Will hold if they are dating or looking for friends"""
    dating = ndb.IntegerProperty()


    
    """This is an array of Strings to hold the Entity Key, or however is best to uniquely identify each user, of every user that the sole user has liked"""
    likedArray = ndb.StringProperty(repeated = True)
    """This is an array of Strings to hold all of the users that the sole user has already seen, however, did not like. Keeps track so user does not see them more that once"""
    skippedArray = ndb.StringProperty(repeated = True)
    """This is an arrary of Strings to hold all of the users that the sole user has liked, that have liked them back. This will be queried when User goes to their messages in order for them to 
    see all of their mathces and who the have the abilty to message"""
    matchedArray = ndb.StringProperty(repeated = True)
    
class PhoneNumber(EndpointsModel):
    """This is a model that will store phone numbers for a brief second in order to verify their phone number, then it will delete"""
    
    """What this message_fields_schmema does is, everything that is in quotations, is accessible, essentially public variables"""
    _message_fields_schema = ("entityKey", "phone_numebr", "confirm_number")
    phone_numebr = ndb.IntegerProperty()
    confirm_number = ndb.IntegerProperty()
 

    

        
    