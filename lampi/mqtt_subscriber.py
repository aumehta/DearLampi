import paho.mqtt.client as mqtt
import base64
import threading
import os
from kivy.app import App
from kivy.clock import Clock

# Purpose: script that is setting up the mqtt client, expecting to receive a base64 encoded image

MQTT_BROKER = "localhost"  # Assuming Mosquitto runs locally on the Pi
MQTT_TOPIC = "dearLampi/incomingMessage"
MQTT_PORT = 1883

# Where decoded image will be saved
IMAGE_PATH = "/home/pi/dearLampi/dearLampi_image_decoded.png"

def on_message(client, userdata, msg):
    print("message received")
    try:
        # Decode base64 image data
        image_data = base64.b64decode(msg.payload)
        with open(IMAGE_PATH, "wb") as img_file:
            img_file.write(image_data)
        print(f"Image received and saved to {IMAGE_PATH}")

        # Force Kivy UI to reload the image
        app = App.get_running_app()
        Clock.schedule_once(lambda dt: app.on_new_message(), 0)
        print("calling on_new_message")
    except Exception as e:
        print(f"Error handling image")


client = mqtt.Client()
client.on_message = on_message
client.connect(MQTT_BROKER, 1883, 60)
client.subscribe(MQTT_TOPIC)
client.loop_forever()
