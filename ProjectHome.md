# Multifit/ Polydefix Polycrystal Deformation using X-rays #

## Scope ##

Multifit/Polydefix is a software package originally written to process data obtained in the D-DIA deformation apparatus efficiently. It allows you to decompose 2D diffraction images into azimuthal slices, fit peak positions and intensities, and propagate the results of your fit to other azimuth and images.

Multifit can fit diffraction data. It will extract d-spacings, intensities, and half-widths for the peaks you're interrested in, for multiple orientations and multiple diffraction images.

Polydefix is for stress and strain analysis. It will start from the output files created in Multifit and extract microscopic strain information from the diffraction images.

Since June 2011, it is open source software, licensed under the [GPL Version 2](GPLVersion2.md).

## Download ##

The latest executables should be in the trunk development tree. Direct links are here
  * for Multifit: [multifit.sav](http://multifit-polydefix.googlecode.com/svn/trunk/Multifit/multifit.sav)
  * for Polydefix: [polydefix.sav](http://multifit-polydefix.googlecode.com/svn/trunk/Polydefix/polydefix.sav)
  * for PolydefixED: [polydefixED.sav](http://multifit-polydefix.googlecode.com/svn/trunk/PolydefixED/polydefixED.sav)

The **download** link at the top of the page might not be up-to-date with the latests fixes. Download archives are only created when there are major changes.

## User manual ##


Polydefix and Multifit are distributed as packages for the [IDL virtual machine](http://www.exelisvis.com/Support/HelpArticlesDetail/TabId/219/ArtMID/900/ArticleID/12395/The-IDL-Virtual-Machine.aspx), which **can be downloaded for free**. There was a change of policy recently and the virtual machine is not so easy to find. Basically, try to create an account and download a trial version of IDL. The trial version of IDL does include the virtual machine. Here is a link with instructions for [starting a virtual machine application](http://www.exelisvis.com/Support/HelpArticlesDetail/TabId/219/ArtMID/900/ArticleID/4633/4633.aspx).

User manuals for multifit and Polydefix are available at this page: http://merkel.zoneo.net/RDX/index.php?n=Multifit.Multifit

## Developer manual ##

All Polydefix and Multifit codes are publicly available. If you want to improve the code, you will have to purchase an IDL licence, download the latest version of the code, and implement your changes. You can learn how to do so by following our [developer manual](DevManual.md).

Please, share the results of your work on this website by uploading your changes and improvements in the main tree, stored here at Google Code. Contact us to learn how to do so.