import 'package:flutter/material.dart';

class AllowPermissions extends StatefulWidget {
  const AllowPermissions({Key? key}) : super(key: key);

  @override
  State<AllowPermissions> createState() => _AllowPermissionsWidgetState();
}

class _AllowPermissionsWidgetState extends State<AllowPermissions> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: double.infinity,
            height: 100,
            child: Align(
              alignment: AlignmentDirectional(0, 0),
              child: Text(
                'ReGroup requires these\npermissions to work properly',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Camera',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Customize your profile by granting camera access for a personal touch.',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFF57636C),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Push Notifications',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Stay connected with your group by enabling push notifications.',
                    style: TextStyle(
                      color: Color(0xFF57636C),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(24, 24, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 100,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bluetooth',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Connect to nearby devices and improve location updates for the ReGroup community.',
                    style: TextStyle(
                      color: Color(0xFF57636C),
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
            child: SizedBox(
              width: double.infinity,
              child: Align(
                alignment: const AlignmentDirectional(0, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(12, 12, 12, 12),
                      child: Material(
                        color: Colors.transparent,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          splashColor: Colors.white,
                          onTap: () => Navigator.pushNamedAndRemoveUntil(
                              context, "/", (route) => false),
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Align(
                              alignment: AlignmentDirectional(0, 0),
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  'Allow permissions',
                                  style: TextStyle(
                                    fontFamily: "Outfit",
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
