import json
from datetime import datetime
import api
import processing
import pandas as pd

# Initial Settings
client_id = '15198'  # app name id
client_secret = '9e93b42206398f186ad1cfa9523d3cb8833a85fc'  # app code
redirect_uri = 'http://localhost/'


with open('strava_tokens.json', 'r') as tokens:
  strava_tokens = json.load(tokens)

refresh_token = strava_tokens['refresh_token']
expires_at = datetime.fromtimestamp(strava_tokens['expires_at'])
now = datetime.now()


# # Refresh if it expires in the next minute
# if (expires_at - now).total_seconds() < 10000000:
#   strava_tokens = api.refresh_token(
#     client_id = client_id,
#     client_secret = client_secret,
#     refresh_token = refresh_token
#   )
#   with open('strava_tokens.json', 'w') as outfile:
#     json.dump(strava_tokens, outfile)

access_token = strava_tokens['access_token']

# get all activities
# all_activities = api.get_all_activities(access_token)

# with open("all_activities.json", "w") as outfile:
#     json.dump(all_activities, outfile)

with open("all_activities.json", "r") as infile:
    all_activities = json.load(infile)

# get all activities id
activities_id = [act['id'] for act in all_activities]

all_activity_details = api.get_all_activity_details(activities_id, access_token)

with open("../data/all_activities_details.json", "w") as outfile:
  json.dump(all_activity_details, outfile)

# all_streams = api.get_all_streams(activities_id, access_token)
# with open("all_streams.json", "w") as outfile:
#    json.dump(all_streams, outfile)

with open("all_streams.json", "r") as infile:
  all_streams = json.load(infile)

df = processing.all_streams2df(all_streams)
df.to_csv("all_activities_df.csv")
