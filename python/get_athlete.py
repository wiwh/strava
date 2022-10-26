import json
import requests

with open('strava_tokens.json', 'r') as tokens:
  data = json.load(tokens)

# Get the access token
access_token = data['access_token']

# Build the API url to get athlete info
athlete_url = f"https://www.strava.com/api/v3/athlete?" \
              f"access_token={access_token}"

# Get the response in json format
response = requests.get(athlete_url)
athlete = response.json()
