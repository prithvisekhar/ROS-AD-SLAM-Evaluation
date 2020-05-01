import os
import rospy
import datetime
from carla_msgs.msg import CarlaEgoVehicleStatus
import psutil
import sys
import csv
process = psutil.Process()

flag=False
f=open(str(sys.argv[2])+".csv",'a')
writer=csv.writer(f)
with f:
    writer.writerow(["DateTime","Ram(MB)","VirtualResource(MB)","CPU(%)","Memory(%)","Runtime","ProcessName","VehicleSpeed"])

def callback(data):
	user=0
	virtualresource=0
	ramresource=0
	pcpu=0
	flag=False
	pmemory=0
	timestamp=0
	data22=[]
	processname=0
	speed=data.velocity
	speedkm=speed*(3600/1000)
	stream=os.popen('top -n 1 -p'+str(int(sys.argv[1])))
	output=stream.read()
	out1=output.split(" ")
	for i in out1:
		if i!='':
		#print(i,out1.index(i))
			if i.find("kankan")!=-1:
				flag=True
			if flag:
				data22.append(i)
	#print(data22)
	ram_mb=data22[4]
	if ram_mb.find("g")!=-1:
		ram_mb=float(ram_mb.replace("g",""))*1024
	Vritual_mb=data22[3]
	if Vritual_mb.find("g")!=-1:
		Vritual_mb=float(Vritual_mb.replace("g",""))*1024
	f=open(str(sys.argv[2])+".csv",'a')
	print(str(datetime.datetime.now()),ram_mb,Vritual_mb,data22[7],data22[8],data22[9],data22[10],speedkm)
	with f:
		writer=csv.writer(f)
		currentDT = datetime.datetime.now()
		writer.writerow([str(currentDT),ram_mb,Vritual_mb,data22[7],data22[8],data22[9],data22[10],speedkm])

def listener():
    rospy.init_node('listener', anonymous=True)
    rospy.Subscriber("/carla/ego_vehicle/vehicle_status", CarlaEgoVehicleStatus, callback)
    rospy.spin()

if __name__ == '__main__':
    listener()

