# Old developer instructions #

Those are older developer instructions, from the time when we were using the graphical development environment for IDL. Please have a look at this [more recent page](DevManual.md) for up-to-date instructions.

## Downloading the code ##

You can get the codes from within IDL. In IDL
  * Select the menu item _Window -> Source Control -> Subversion_. It may ask you to install some extension. To be honest, I can't remember which one I chose.
  * You will see a tab _SVN Repositories_, click on the _New repository location_ icon.
  * Enter the URL, listed above, and give it a label such as _Multifit_, _Polydefix_, or _PolydefixED_,
  * Username and password are not necessary to get the code, but will be required if you want to upload your code back.
  * In the _SVN Repositories_ view, right click on the project name on the SVN server, select _Checkout_,
  * IDL will then copy the current version of Multifit into your working directory.
  * To start working on your own copy, open the _Project view_ in IDL. What you downloaded will show up as a project with the label you chose earlier.

## Updating your version ##

If you want to update the version you have and download the most current version, right click on the repository name and select _Checkout_.

## Working on the code ##

You can word on your local copy, which should be somewhere in your project tree.

To compile:
  * Right click on the project name in the project explorer and select _Define as working directory_. This should be done once.
  * In the IDL console, type `@build`

This will compile all files and create the sav archive you can run from the IDL virtual machine.

To run from within IDL,
  * type `polydefixED` to run polydefixED
  * type `polydefix` to run polydefix
  * type `Multifit` to run Multifit

## Upload your changes ##

Only people allowed by me, S. Merkel, will be allowed to upload changes. I am fairly open though, just ask for permission.

Once you feel ready, upload your changes. To do so, right click on the project name and select _Team -> Commit_. In the dialog, leave a comment giving people an idea of what you did. This is mandatory or you will be kicked out of the project.

Last advise: upload your changes often to avoid conflicts with other developers.

## Creating a new branch ##

Once we feel we are ready for a new version, I will create a new "Branch" with the command
```
svn copy https://multifit-polydefix.googlecode.com/svn/trunk/Multifit https://multifit-polydefix.googlecode.com/svn/branches/Multifit-X.X -m "Creating version XXX"
```