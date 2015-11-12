# opengl-osx
A base setup to get OpenGL running for the SuperBible Sixth Edition

A simple project that sets up what is needed to run through the examples in the OpenGL SuperBible Sixth Edition.

I created this because I found it extremely difficult to find support for OpenGL on current OS X systems and I find myself continually going through the book time and time again to re-learn the framework. I decided on Objective-C since it can compile C/C++ code natively and also because the code completion for the OpenGL commands actually work. In Swift it does not and the compiled setup that the SuperBible 6 walks you through does not either making it a bit more difficult to simply learn the functions and what they accept for inputs.

What this will do is provide what is needed to simply startup Xcode and start running your code following along with the Superbible Book. The entire first section should work for this (chapters 1-6) with the exception of the tunnels example in chapter 5 as the shader does not work for OpenGL v4.1. I have not tested the next two sections and I am sure that there will be things missing. As I follow through this publication I will update this project accordingly to ensure the next sections will properly function.

How to use this:
1. Open the project in Xcode.
2. Create a new file that is a subclass of BaseOpenGLView.
3. Go to Main.storyboard and set the ViewController's view to the subclass that you just created.
4. Implement the following 3 functions:
    - (void)startUp;
    - (void)shutDown;
    - (void)render:(double)currentTime;

5. Follow the book and you are on your way to learning some OpenGL!

6. Please add things to this as you go! While I do program for a living, this is the first public project I have ever posted so I am open to a bit of feedback, suggestions, and better approaches to what I have put together here!
