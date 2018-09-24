data = csvread('withMovesannotated.csv',1,0);
jawOpen = data(:,1);
mouthLowerDown_R = data(:,2);
mouthLowerDown_L = data(:,3);
mouthStretch_R = data(:,4);
mouthStretch_L = data(:,5);
mouthPucker = data(:,6);
mouthFrown_R = data(:,7);
mouthFrown_L = data(:,8);
mouthClose = data(:,9);
mouthFunnel = data(:,10);
mouthUpperUp_L = data(:,11);
mouthUpperUp_R = data(:,12);
jawForward = data(:,13);
mouthShrugLower = data(:,14);
mouthShrugUpper = data(:,15);
jawRight = data(:,16);
jawLeft = data(:,17);
mouthDimple_L = data(:,18);
mouthDimple_R = data(:,19);
mouthRollLower = data(:,20);
mouthRollUpper = data(:,21);
mouthLeft = data(:,22);
mouthRight = data(:,23);
mouthSmile_L = data(:,24);
mouthSmile_R = data(:,25);
mouthPress_L = data(:,26);
mouthPress_R = data(:,27);
movement = data(:,28);
x = 0:1:size(jawOpen,1)-1;
plot(x, jawOpen, x, mouthLowerDown_R, x, mouthLowerDown_L, x, mouthStretch_R, x, mouthStretch_L, x, mouthPucker, x, mouthFrown_R, x, mouthFrown_L, x, mouthClose, x, mouthFunnel, x, mouthUpperUp_L, x, mouthUpperUp_R, x, jawForward, x, mouthShrugLower, x, mouthShrugUpper, x, jawRight, x, jawLeft, x, mouthDimple_L, x, mouthDimple_R, x, mouthRollLower, x, mouthRollUpper, x, mouthLeft, x, mouthRight, x, mouthSmile_L, x, mouthSmile_R, x, mouthPress_L, x, mouthPress_R, x, movement);