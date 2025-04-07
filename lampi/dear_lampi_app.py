from kivy.app import App
from kivy.uix.anchorlayout import AnchorLayout
from kivy.uix.screenmanager import ScreenManager, Screen, FadeTransition
from kivy.uix.label import Label
from kivy.animation import Animation
from kivy.clock import Clock
from kivy.uix.image import Image
from paho.mqtt.client import Client
from dear_lampi_light_mode import twinkle, stop_led
import base64
import threading
import os
import json
from PIL import Image, ImageDraw, ImageFont
import io

# This file is setting the mqtt client to listen in on the topic dearLampi/incomingMessage and defines the logic for
# the screen manager when a new message is received.

def get_device_id():
    mac_addr = open(DEVICE_ID_FILENAME).read().strip()
    return mac_addr.replace(':', '')

DEVICE_ID_FILENAME = '/sys/class/net/eth0/address'
DEVICE_ID = get_device_id()

IMAGE_PATH = "/home/pi/dearLampi/lampi/received_images/dearLampi_image_decoded.png"
MQTT_BROKER = "localhost"
MQTT_TOPIC = "swift/#"
MQTT_PORT = 1883

class BouncingLabel(Label):
    def bounce(self):
        anim = Animation(pos_hint={"center_y": 0.2}, duration=0.5) + \
               Animation(pos_hint={"center_y": 0.27}, duration=0.5)
        anim.repeat = True
        anim.start(self)

# Screensaver screen
class Screen1(Screen):
    pass

# incoming message screen
class Screen2(Screen):
    print("in screen2")
    def on_pre_enter(self):
        Clock.schedule_once(self.start_bounce, 0.1)

    def start_bounce(self, dt):
        if "bounce_label" in self.ids:
            self.ids.bounce_label.bounce()

    def on_touch_down(self, touch):
#       self.manager.transition = FadeTransition(duration=1)
        stop_led()
        self.manager.current = "display message"
        return super().on_touch_down(touch)

# display message screen
class Screen3(Screen):
    print("screen3")
    def on_pre_enter(self):
        Clock.schedule_once(self.update_image, 0.1)

    def on_touch_down(self, touch):
  #     self.manager.transition = FadeTransition(duration=1)
        self.manager.current = "screensaver"
        return super().on_touch_down(touch)

    def update_image(self, dt):
        """Update the image when entering Screen2"""
        if os.path.exists(IMAGE_PATH):
            self.ids.received_image.source = IMAGE_PATH
            self.ids.received_image.reload()

# main class
class dear_lampiApp(App):
    def build(self):
        sm = ScreenManager()
        sm.add_widget(Screen1(name="screensaver"))
        sm.add_widget(Screen2(name="incoming message"))
        sm.add_widget(Screen3(name="display message"))
        self.sm = sm

        threading.Thread(target=self.setup_mqtt, daemon=True).start()
        return sm

    # Changes to screen2 when there is a new message received
    def on_new_message(self):
        self.sm.current = "incoming message"


    def setup_mqtt(self):
        def on_message(client, userdata, msg):
            print("Received on topic:", msg.topic)
            try:
                payload = json.loads(msg.payload.decode())
                image_data = payload["background"]
                light_mode = payload["alert_light"]
                message = payload["message"]

                # decode the image data and save it in the file path
                with open(IMAGE_PATH, "wb") as img_file:
                    img_file.write(base64.b64decode(image_data))
                print("Image written to:", IMAGE_PATH)

                # Overlay the message text
                overlay_text_on_image(IMAGE_PATH, message, IMAGE_PATH)
                print("Message added to image.")

                if light_mode == "twinkle":
                    twinkle()

                #if light_mode == "rainbow":
                 #   set_rainbow()
                app = App.get_running_app()
                if app is None:
                    print("App instance is None — Kivy app may not be running yet")
                else:
                    print("else")
                    Clock.schedule_once(lambda dt: app.on_new_message(), 0)

                # Switch screen from screensaver → incoming message
                #Clock.schedule_once(lambda dt: self.on_new_message())

            except Exception as e:
                print("Error handling image:", e)

        client = Client()
        client.on_message = on_message
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.subscribe(MQTT_TOPIC)
        print(MQTT_TOPIC)
        print("MQTT client connected and listening...")

        client.loop_forever()

# method to add text to image
def overlay_text_on_image(image_path, text, output_path):
    image = Image.open(image_path).convert("RGBA")
    draw = ImageDraw.Draw(image)

    # Load font
    try:
        font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", size=30)
    except:
        font = ImageFont.load_default()

    # Get text size and position
#    text_width, text_height = draw.textsize(text, font=font)
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]

    x = (image.width - text_width) // 2
    y = (image.height - text_height) //2

    # Optional: Add a black rectangle behind text for contrast
    #padding = 10
    #draw.rectangle(
     #   [x - padding, y - padding, x + text_width + padding, y + text_height + padding],
      #  fill=(0, 0, 0, 180)
    #)

    # Draw the text in white
    draw.text((x, y), text, font=font, fill="black")

    # Save the new image
    image.save(output_path)
