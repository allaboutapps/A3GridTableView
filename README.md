 
#What is A3GridTableView?
**A3GridTableView** is a `UIScrollView` subclass with a high performance GridView style layouting.  
It has similar delegate methods to a `UITableView` and can be even used like one.  
The difference is that the **A3GridTableView** aligns his section in collumns and not in one flow.

It is written in *Objective-C* and works for all iOS applications and uses ARC.

##Video:
![A3GridTableView iPhone sample](https://dl.dropbox.com/u/9934540/aaa/A3GridTableViewSampleIPhone.gif "A3GridTableView iPhone Sample Video")
![A3GridTableView iPad sample](https://dl.dropbox.com/u/9934540/aaa/A3GridTableViewSampleIPad.gif "A3GridTableView iPad Sample Video")


##Usage:

Initialize a **A3GridTableView** like any other View by code or in the InterfaceBuilder.
Set your ViewController as dataSource and delegate of the **A3GridTableView** and implement the required dataSource methods:

    - (NSInteger)numberOfSectionsInA3GridTableView:(A3GridTableView *) gridTableView;
    - (NSInteger)A3GridTableView:(A3GridTableView *) tableView numberOfRowsInSection:(NSInteger) section;
    - (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)gridTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

You can find all optional dataSource and delegate methods like `heightForRowAtIndexPath:` well documented with explanations in the [A3GridTableView.h header](https://github.com/allaboutapps/A3GridTableView/blob/master/A3GridTableView/A3GridTableView.h) file.  

The dataSource method `cellForRowAtIndexPath:` requires a **A3GridTableViewCell** (or a subclass) which properties can also be seen in [A3GridTableViewCell.h header](https://github.com/allaboutapps/A3GridTableView/blob/master/A3GridTableView/A3GridTableViewCell.h) file.
 
#License:
[See our BSD 3-Clause License](https://github.com/allaboutapps/A3GridTableView/blob/master/LICENSE.txt)

#Contribute:
Feel free to fork and make pull requests! We are also very happy if you tell us about your app(s) which use this control.  


![aaa - AllAboutApps](https://dl.dropbox.com/u/9934540/aaa/aaaLogo.png "aaa - AllAboutApps")  
[© allaboutapps 2013](http://www.allaboutapps.at)