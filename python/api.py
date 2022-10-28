import requests
import json
import time

def refresh_token(client_id, client_secret, refresh_token):

    # Refresh access token
    tokens = requests.post(url='https://www.strava.com/oauth/token',
                           data={'client_id': client_id,
                                 'client_secret': client_secret,
                                 'refresh_token': refresh_token,
                                 'grant_type': 'refresh_token'})
    # Save json response as a variable
    strava_tokens = tokens.json()

    return strava_tokens
def get_activities(access_token, page=1, per_page="100", before="", after=""):
  url = f"https://www.strava.com/api/v3/activities?" +\
    f"access_token={access_token}" +\
    f"&page={page}&per_page={per_page}" +\
      "&include_all_efforts=true"

  response = requests.get(url)
  activities = response.json()

  return(activities)

def get_all_activities(access_token):
  activities = []
  page = 0
  while True:
    page += 1
    print(f"Fetching data on page {page}.")
    new_activities = get_activities(access_token, page=page) 
    if (len(new_activities) == 0) or (type(new_activities) is dict):
      break
    else:
      activities += new_activities
  
  return activities

def get_activity_details(activity_id, access_token):
  url = f"https://www.strava.com/api/v3/activities/{activity_id}?" + \
    f"access_token={access_token}&include_all_efforts=true"
  response = requests.get(url)
  activities = response.json()
  return(activities)

def get_all_activity_details(activities_id, access_token, streams="all", time_per_request=1.8):
  '''
  time_per_request makes it so that the requests are not too fast and end up blocked.
  Make sure the access token is reset prior to running this function.
  '''
  all_efforts = []
  for i in range(len(activities_id)):
    t0 = time.time()
    
    print(f"Querrying activity {i}/{len(activities_id)} with id {activities_id[i]}...", end = "")

    new_entry = {
      'activity_id' : activities_id[i],
      'activity_details' : get_activity_details(
        activities_id[i], 
        access_token)
      }
    
    print(" Success!")

    all_efforts.append(new_entry)

    t1 = time.time()
    time.sleep(max(time_per_request - (t1-t0), 0))

  return(all_efforts)


def get_streams(activity_id, access_token, streams="all"):
  if streams == "all":
    streams = ["time", "distance", "latlng", "altitude", "velocity_smooth", "heartrate", "cadence", "watts", "temp", "moving", "grade_smooth"]
  url = f"https://www.strava.com/api/v3/activities/{activity_id}/streams/" + \
    ",".join(streams) + f"?access_token={access_token}"
  response = requests.get(url)
  activities = response.json()
  return(activities)

def get_all_streams(activities_id, access_token, streams="all", time_per_request=1.8):
  '''
  time_per_request makes it so that the requests are not too fast and end up blocked.
  Make sure the access token is reset prior to running this function.
  '''
  all_streams = []
  for i in range(len(activities_id)):
    t0 = time.time()
    
    print(f"Querrying activity {i}/{len(activities_id)} with id {activities_id[i]}...", end = "")


    new_entry = {
      'activity_id' : activities_id[i],
      'activity_streams' : get_streams(
        activities_id[i], 
        access_token, 
        streams)
      }
    
    print(" Success!")

    all_streams.append(new_entry)

    t1 = time.time()
    time.sleep(max(time_per_request - (t1-t0), 0))

  return(all_streams)