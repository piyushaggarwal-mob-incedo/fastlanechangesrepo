#!/bin/bash
#!/usr/local/bin/
#!/usr/bin/env
#!/usr/bin/ruby

echo "jukinvideo"
python ./iOS/AppCMS/fastlane.py appleTv http://appcms-config.s3.amazonaws.com/be98b78d-605d-42fb-a8ba-80b10dafa733/_temp/build/appleTv/build.json jukinvideo 645 http://staging4.partners.viewlift.com/jukinvideo/appleTv/appcms/build/status
#python ./iOS/AppCMS/fastlane.py ios http://appcms-config.s3.amazonaws.com/be98b78d-605d-42fb-a8ba-80b10dafa733/_temp/build/ios/build.json jukinvideo 680 http://staging4.partners.viewlift.com/jukinvideo/ios/appcms/build/status

