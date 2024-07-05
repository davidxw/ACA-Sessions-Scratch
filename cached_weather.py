
import os
import requests
import json

def get_local_weather(key, location="Sydney"):
    # Define the URL for the weather API
    weather_api_url = f"http://api.weatherapi.com/v1/current.json?key={key}&q={location}&aqi=no"
    
    # Check if the weather data is already cached
    cached_weather = os.getenv("CACHED_WEATHER")
    
    if cached_weather:
        print("Using cached weather data.")
        weather_data = json.loads(cached_weather)
    else:
        print("I'm new here! Fetching new weather data.")
        response = requests.get(weather_api_url)
        if response.status_code == 200:
            weather_data = response.json()
            # Cache the weather data as a JSON string in an environment variable
            os.environ["CACHED_WEATHER"] = json.dumps(weather_data)
        else:
            print("Failed to fetch weather data.")
            return None
    
    # Extract and print the relevant weather information
    location = weather_data["location"]["name"]
    temperature = weather_data["current"]["temp_c"]
    condition = weather_data["current"]["condition"]["text"]
    
    print(f"Weather in {location}: {temperature}°C, {condition}") 
    
