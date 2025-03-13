import 'package:flutter/material.dart';

class Profile extends StatefulWidget{
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile>{
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(top: 10, left: 20, right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color.fromRGBO(54, 105, 201, 1),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: SizedBox(
          height: 100,
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(left: 20),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.istockphoto.com%2Fphotos%2Fcorporate-profile-picture&psig=AOvVaw3Fn5EL7EyW3_iJWu_F9p9J&ust=1741920875804000&source=images&cd=vfe&opi=89978449&ved=0CBEQjRxqFwoTCJDk742HhowDFQAAAAAdAAAAABAI'),
                ),
              ),
              Text('Profile Page'),
              Text('This is the profile page'),
            ],
          ),
        ),
      )
    );
  }
}