from kivy.app import App
from kivy.uix.anchorlayout import AnchorLayout
from kivy.uix.screenmanager import ScreenManager, Screen, FadeTransition
from kivy.uix.label import Label
from kivy.animation import Animation
from kivy.clock import Clock
from kivy.uix.image import Image
from paho.mqtt.client import Client
import base64
import threading
import os

# This file is setting the mqtt client to listen in on the topic dearLampi/incomingMessage and defines the logic for
# the screen manager when a new message is received.

IMAGE_PATH = "/home/pi/dearLampi/lampi/received_images/dearLampi_image_decoded.png"
MQTT_BROKER = "localhost"
MQTT_TOPIC = "dearLampi/incomingMessage"
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
            print("MQTT message received.")
            try:
                # decode the image data and save it in the file path
                image_data = base64.b64decode(msg.payload)
                with open(IMAGE_PATH, "wb") as img_file:
                    img_file.write(image_data)
                print("Image written to:", IMAGE_PATH)

                # Switch screen from screensaver → incoming message
                Clock.schedule_once(lambda dt: self.on_new_message())

            except Exception as e:
                print("Error handling image:", e)

        client = Client()
        client.on_message = on_message
        client.connect(MQTT_BROKER, MQTT_PORT, 60)
        client.subscribe(MQTT_TOPIC)
        print("MQTT client connected and listening...")

        client.loop_forever()
