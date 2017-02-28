//
//  ViewController.h
//  DictTest
//
//  Created by Wagner Truppel on 4/14/09.
//  Copyright Wagner Truppel 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController: UIViewController
{
    @private

	IBOutlet UITextField* stringDictNumWordsTF;
	IBOutlet UITextField* stringDictTimeTF;

    IBOutlet UITextField* stdioDictNumWordsTF;
	IBOutlet UITextField* stdioDictTimeTF;

	IBOutlet UITextField* txtNumWordsTF;
	IBOutlet UITextField* txtTimeTF;

    IBOutlet UITextField* xmlNumWordsTF;
    IBOutlet UITextField* xmlTimeTF;

    IBOutlet UITextField* binNumWordsTF;
    IBOutlet UITextField* binTimeTF;

    IBOutlet UITextField* lazyNumWordsTF;
    IBOutlet UITextField* lazyTimeTF;

        IBOutlet UIButton*    reloadBtn;
}

- (IBAction) actionReload: (id) sender;

@end
