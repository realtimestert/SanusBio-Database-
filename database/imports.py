import requests

token = "YOUR_API_TOKEN"
sheet_id = "YOUR_SHEET_ID"

url = f"https://api.smartsheet.com/2.0/sheets/{sheet_id}"
headers = {
    "Authorization": f"Bearer {token}"
}

response = requests.get(url, headers=headers)
data = response.json()

print(data)

#framework for importing data from smartsheets
# use python to convert to sql