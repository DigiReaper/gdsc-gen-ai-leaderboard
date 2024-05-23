import firebase_functions as functions
from firebase_functions import scheduler_fn
from firebase_admin import credentials, firestore, initialize_app
import requests
from bs4 import BeautifulSoup
from datetime import datetime
import pytz

now_utc = datetime.now(pytz.timezone('UTC'))
now_ist = now_utc.astimezone(pytz.timezone('Asia/Kolkata'))

cred = credentials.Certificate('key.json')  # replace with your service account key's path
default_app = initialize_app(cred)
db = firestore.client()


# Schedule a function to run every 30 minutes at the start of every hour and then 30 minutes later.
# schedule.on_schedule().every_minutes(29).at("00:01").target(update_data)

@scheduler_fn.on_schedule(schedule="0 * * * *")

# Define the function that will be triggered.
def update_data(event: scheduler_fn.ScheduledEvent) -> None:
    print("Function triggered from", event.schedule_time)
    # Get all documents from the 'user_data' collection
    docs = db.collection('user_data').get()

    db.collection('execution').document('update_log').update({
    'lastupdated': now_ist
    })

    # Iterate over the documents
    for doc in docs:
        # Get the 'url' field
        url = doc.to_dict().get('url')
        email = doc.to_dict().get('email')

        # Send a GET request to the URL
        try :
            response = requests.get(url)
            if response.status_code != 200:
                print(f"Error: Failed to fetch URL {url}")
                continue
            
            # Parse the response content with BeautifulSoup
            soup = BeautifulSoup(response.content, 'html.parser')

            # Search for the specified strings in the parsed content
            genai_apps = "Develop GenAI Apps with Gemini and Streamlit" in soup.text
            arcade = "Level 3: GenAIus Registries" in soup.text
            prompt_design = "Prompt Design in Vertex AI" in soup.text
            
            # Check if all variables are True
            total_completion = genai_apps and arcade and prompt_design
            
            print(f"Email: {email}")
            print(f"URL: {url}")
            print(f"genai_apps: {genai_apps}, arcade: {arcade}, prompt_design: {prompt_design}, total_completion: {total_completion}")
            print("--------------------\n")
            
            # Update the Firestore document
            db.collection('user_data').document(doc.id).update({
                'genai_apps': genai_apps,
                'arcade': arcade,
                'prompt_design': prompt_design,
                'total_completion': total_completion
            })
        
        except Exception as e:
            print(f"Error: {e}")
            print("--------------------\n")
            print("Writing to error log")
            db.collection('execution').document('error_log').update({
            str(now_ist): str(e)
            })
            continue