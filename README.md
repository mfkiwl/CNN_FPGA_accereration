# CNN_FPGA_accereration

CNN convolution 을 FPGA ( xilinx zinq 7000 ) 의 arm processor를 이용해 진행한다.

verilog HDL를 이용해 제어하였으며 AHB AMBA 버스 시스템으로 통신하였다.

1. Object project
• Convolutional Neural Network (CNN).
- Convolutional Neural Network (After is CNN) is one of most popular Deep
Neural network. CNN has advantage in classification images.
• In this project, Students make one part CNN by using FPGA.
• measure total calculate time and revise your design to decrease calculation
time.

2. Theory
• There is 3 layer in the CNN.
• The first layer is convolution layer. This layer detect the feature image. 2D Convolution is used to extract feature.
• The second layer is pooling layer. This layer regulates over-fitting and decrease calculation
• The third layer is fully-connected layer. This layer classifies the feature map to get the class of input data.
• To keep multi-layer feature, each layer has activation function. There are many kind of activation function, however, in this project only use ReLU(Retified Linear Unit) function.
※ 2D convolution
- In mathematics (in particular, functional analysis) convolution is a
mathematical operation on two functions (f and g) to produce a third function that expresses how the shape of one is modified by the other. It is a cross-correlation of f (x) and g(−x), or f (−x) and g(x). Similar one-dimensional case, 2D convolution is a mathematical operation on two function (f and g) that is sliding g to f or f to g each stride. In discrete case, each element do dot product and sum.
  2D convolution stride 1
※ Max pooling
- In pooling layer, there are 2 pooling technique. One is Max pooling and the
other is average pooling. Max pooling is, we can know it’s name, extract max number in the window. Average pooling is extract average number in the window.
 ※ ReLu fuction
- ReLu(Rectified Linear Unit) is
diminish negative value.
 ReLu
※ Fixed-point value
- Fixed point is an intermediate implementation close to the integer
implementation, which allows partially modeling fractional numbers. Fixed point number are useful for representing fractional values, usually in base 2 or base 10. In fixed point, negative value is represented 2’s complement.

