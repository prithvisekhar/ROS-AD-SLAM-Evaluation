#!/usr/bin/env python
import rospy
import roslib
from nav_msgs.msg import Odometry
import sys
import glob
from geometry_msgs.msg import Twist
sys.path.append('/home/kankan/carla/Dist/CARLA_Shipping_0.9.8-162-g30edd5ce/LinuxNoEditor/PythonAPI/carla/dist/carla-0.9.8-py2.7-linux-x86_64.egg')

import carla
from carla_msgs.msg import CarlaEgoVehicleControl
import std_msgs
from pynput.keyboard import Key, Listener

speed=0.0
threshold=0.2
offset=0
steer=0.0
vel_msg=CarlaEgoVehicleControl()
velocity_publisher = rospy.Publisher('/carla/ego_vehicle/vehicle_control_cmd', CarlaEgoVehicleControl, queue_size=10)





class KeyboardPublisher:

    def on_press(self, key):
        global steer
        #print(key) #<-- this prints out the key press and then crashes
        try:    
            if key.char=='d' and steer<1:
                steer=steer+0.2
            if key.char=='a' and steer>-1:
                steer=steer-0.2
        except AttributeError:
            pass

    def on_release(self, key):
        print('{0} release'.format(
            key))
        if key == Key.esc:
            # Stop listener
            return False

    def keyboard_listener(self):
        # Collect events until released
        with Listener(
                on_press=self.on_press,
                on_release=self.on_release) as listener:
            listener.join()

def odometryCb(msg):
    global steer
    h = std_msgs.msg.Header()
    h.stamp = rospy.Time.now() # Note you need to call rospy.init_node() before this will work
    print(msg.twist.twist.linear.x)
    speed=msg.twist.twist.linear.x
    offset=speed-threshold
    if offset<0:
        offset=0
    print("Speed====",offset)
    vel_msg.header=h
    try:
        keys()
    except:
        pass
	
    if speed>threshold:
        print("Decellerate")
        if(vel_msg.throttle>0.1):
	    vel_msg.throttle-=0.01
        else:
            pass
    else:
    	print("Accelerte")
        if(vel_msg.throttle<0.9):
	    vel_msg.throttle=0.5
        else:
            pass
            
    if steer>0 and steer<1:
        steer=steer-0.005
    elif steer<0 and steer>-1:
        steer=steer+0.005
    else:
        pass
    print('Steer=',steer)
    vel_msg.steer=steer
    velocity_publisher.publish(vel_msg)

def callback(data):
    rospy.loginfo(rospy.get_caller_id() + "I heard %s", data.data)


def keys():
    k=ord(getch.getch())# this is used to convert the keypress event in the keyboard or joypad , joystick to a ord value
    print(str(k))



if __name__ == '__main__':
    rospy.init_node('oodometry', anonymous=True) #make node 
    rospy.Subscriber('/carla/ego_vehicle/odometry',Odometry,odometryCb)
    keyboard_publisher = KeyboardPublisher()
    keyboard_publisher.keyboard_listener()
    rospy.spin()



