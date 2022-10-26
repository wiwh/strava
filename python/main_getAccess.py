import json
import os
import requests
import time
import APIauth

# Initial Settings
client_id = '15198'  # app name id
client_secret = 'fcdfc8e4d7b466cca9053953bbf35590c51f181e'  # app code
redirect_uri = 'http://localhost/'

# Authorization URL
request_url = f'http://www.strava.com/oauth/authorize?client_id={client_id}' \
                  f'&response_type=code&redirect_uri={redirect_uri}' \
                  f'&approval_prompt=force' \
                  f'&scope=profile:read_all,activity:read_all'

#%%
# User prompt showing the Authorization URL
# and asks for the code
print('Click here:', request_url)
print('Please authorize the app and copy&paste below the generated code!')
print('P.S: you can find the code in the URL')
code = input('Insert the code from the url: ')

# Get the access token
tokens = requests.post(url='https://www.strava.com/oauth/token',
                       data={'client_id': client_id,
                             'client_secret': client_secret,
                             'code': code,
                             'grant_type': 'authorization_code'})




#Save json response as a variable
strava_tokens = tokens.json()

with open('strava_tokens.json', 'w') as outfile:
  json.dump(strava_tokens, outfile)

# to refresh the token

with open('strava_tokens.json', 'r') as tokens:
  data = json.load(tokens)

refresh_token = data['refresh_token']
strava_tokens = APIauth.refresh_token(
  client_id = client_id,
  client_secret = client_secret,
  refresh_token = refresh_token)

with open('strava_tokens.json', 'w') as outfile:
  json.dump(strava_tokens, outfile)