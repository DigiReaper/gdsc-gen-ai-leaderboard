import pandas as pd
from firebase_admin import credentials, firestore, initialize_app

# Initialize Firestore
cred = credentials.Certificate('key.json')  # replace with your service account key's path
default_app = initialize_app(cred)
db = firestore.client()

# Read CSV file
df = pd.read_csv('./sheet.csv')

# Convert 0 and 1 to False and True respectively
df['prompt_design'] = df['prompt_design'].map({0: False, 1: True})
df['genai_apps'] = df['genai_apps'].map({0: False, 1: True})

# Convert 'No' and 'Yes' to False and True respectively
df['total_completion'] = df['total_completion'].map({'No': False, 'Yes': True})

# df = df.iloc[:2]

# Convert DataFrame to dictionary
data_dict = df.to_dict('records')

print(data_dict)

# Push data to Firestore
for item in data_dict:
    db.collection('user_data').document(item['email']).set(item)