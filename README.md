# FireWeather.
## Follw the steps below to build and run this project
1. Clone the project
2. Open in xcode, recommended xcode version is 6.3
3. Add Alamofire and SwiftyJSON in Embedded binaires by...
  * Click on FireWeather on the directory in the left side of xcode
  * Under General tab scroll down to **Embedded binaries**
  * Click the **+** icon
  * While holding Command key select SwiftyJSON.framework and Alamofire.framework under SwiftyJSON.xcodeproj and Alamofire.xcodeproj respectively
  * Finally, click the **Add** button
4. Firebase depends on these other frameworks. Add them to your project:
  * Still under the General tab of FireWeather, scroll down to **Linked Frameworks and Libraries**, click the **+** icon and add the following libraries..
  * libicucore.dylib
  * libc++.dylib
  * CFNetwork.framework
  * Security.framework
  * SystemConfiguration.framework
  * skip this step if there is Firebase.framework already, else add it
5. Finally click on Build Settings tab, search for **other linker flags**, select Other Linker Flags and press Enter button. Now copy and paste **-ObjC** into the text field and click enter button once again. You can now ruild and run the project using **Command + R**
