#!/bin/sh
#!/bin/bash
#!/usr/bin/env python


import json
import subprocess
import socket
import os
import sys
import datetime
import plistlib
import glob
import urllib
import collections
import boto3

from subprocess import call

from datetime import datetime
from time import gmtime, strftime
from collections import OrderedDict

SeparatorLine = '--------------------------------------------------------------'

print('\n\n'+SeparatorLine+'\n************ Welcome to Fastlane Job Manager ************\n' + SeparatorLine)
print 'FastlaneJobManager:Start execution at '+datetime.now().strftime('%Y-%m-%d %H:%M:%S')

fileDirPath = os.path.dirname(os.path.abspath(__file__))
os.chdir(fileDirPath)
print 'FastlaneJobManager:PATH='+os.getcwd()

jobPlistFileName = 'Job.plist'
# Create SQS client
sqs = boto3.client('sqs')

# queue_url='https://sqs.us-east-1.amazonaws.com/053866237477/Fastlane_Production_queue.fifo'
queue_url = 'https://sqs.us-east-1.amazonaws.com/053866237477/Fastlane_staging_queue.fifo'
#queue_url = 'https://queue.amazonaws.com/053866237477/Fastlane_Dev_queue.fifo'

info_filename = os.path.join(os.getcwd(), jobPlistFileName)
if os.path.isfile(info_filename):
    info = plistlib.readPlist(info_filename)
    isJobInProgress = info['JobExecutionInProgress']
    JobBuildId = info['JobBuildId']
    JobBuildPlatform = info['JobBuildPlatform']
    
    if isJobInProgress == False:
        info['JobExecutionInProgress'] = True
        plistlib.writePlist(info, jobPlistFileName)
        # Receive message from SQS queue
        print 'FastlaneJobManager:SQS:Fetching message from SQS'
        response = sqs.receive_message(
                                       QueueUrl=queue_url,
                                       AttributeNames=['All'],
                                       MaxNumberOfMessages=1,
                                       MessageAttributeNames=['All']
                                       )
        if 'Messages' in response:
            message = response['Messages'][0]
            ReceiptHandle = message['ReceiptHandle']
            messageId=message['MessageId']
            body = message['Body']
            
            # Delete received message from queue
            print 'FastlaneJobManager:SQS:Removing received message from SQS and process build'
            sqs.delete_message(
                               QueueUrl=queue_url,
                               ReceiptHandle=ReceiptHandle
                               )
            print 'Removed Message from SQS [MessageId#'+messageId+']\n************ Build Process Start ************'
            
            # bodyInfo = json.loads(body)
            # platform = bodyInfo['platform']
            # jsonURL = bodyInfo['buildDetails']
            # siteName = bodyInfo['site']
            # buildId = bodyInfo['buildId']
            # hostname = 'http://staging4.partners.viewlift.com'#bodyInfo['hostname']
            
            bodyInfo = json.loads(body)

            print bodyInfo

            
            platform = bodyInfo['platform']
            jsonURL = bodyInfo['buildDetails']
            siteName = bodyInfo['site']
            buildId = bodyInfo['buildId']
            hostname = bodyInfo['serverBaseUrl']
            bucketName = bodyInfo['bucketName']
            myEmail = bodyInfo['userName']

            info['JobBuildId'] = buildId
            info['JobBuildPlatform'] = platform
            plistlib.writePlist(info, jobPlistFileName)
            info['JobBuildStatus'] = False

            postUrl = hostname +'/'+siteName+'/'+platform+'/appcms/build/status'
            
            if platform == 'ios' or platform == 'appleTv':
                # subprocess.call('python ./iOS/AppCMS/fastlane.py '+ platform +' '+jsonURL+' '+siteName+' '+buildId + ' ' + postUrl +'', shell=True)
                #Passing Parameters to the Fastlane Python Scripts::
                print 'python ./iOS/AppCMS/fastlane.py '+ platform + ' ' +  jsonURL + ' ' + siteName + ' ' + str(buildId) + ' ' + hostname + ' ' + bucketName + ' ' + myEmail
                subprocess.call('python ./ios/AppCMS/fastlane.py '+ platform + ' ' +  jsonURL + ' ' + siteName + ' ' + str(buildId) + ' ' + hostname + ' ' + bucketName + ' ' + myEmail, shell=True)
                info['JobBuildStatus'] = True
            elif platform == 'android' or platform == 'fireTv':
                subprocess.call('python ./android-appcms/fastlanedemo.py '+ platform + ' ' +  jsonURL + ' ' + siteName + ' ' + str(buildId) + ' ' + hostname + ' ' + bucketName+ ' ' + myEmail, shell=True)
                print 'Changing the build status'
                info['JobBuildStatus'] = True
            else:
                #Add for more platform
                info['JobBuildStatus'] = True
        else:
            print 'FastlaneJobManager:SQS:Empty Queue:No Message Received'

        info['JobExecutionInProgress'] = False
        plistlib.writePlist(info, jobPlistFileName)
    else:
        info['JobExecutionInProgress'] = False
        print 'FastlaneJobManager:Already Build processing:Build id=['+str(JobBuildId)+'] Plateform=['+JobBuildPlatform+']'
else:
    print 'FastlaneJobManager:ERROR:Unable to load Job.plist'

print 'FastlaneJobManager:Finished at '+datetime.now().strftime('%Y-%m-%d %H:%M:%S') + '\n' + SeparatorLine + '\n'
