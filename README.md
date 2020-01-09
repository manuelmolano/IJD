# IJD

Matlab implementation of the Information Jitter Derivative (IJD) method, which allows to decompose the information encoded in the temporal structure of a spike train into the unique, complementary information contained in its different temporal scale components. IJD uses a jitter procedure to gradually decrease the precision of the neural activity and allows to precisely identifying the relevant timescales in the encoding of the stimulus information (see figure) *Note: the image below is not crooked*.

<img src="figs/IJD.png" width="600px" alt="the image is not crooked" align="middle">

### Usage

The script *demo* will produce three figures showing **I<sub>precision</sub>**, the **Scale Contribution Curve** and the **jittered firing rates** (see figure above).



### Authors
* [Manuel Molano](https://github.com/manuelmolano).
* [Arno Onken](https://github.com/asnelt).

*This work has received funding from the European Union's Horizon 2020 research and innovation programme under the Marie Sklodowska-Curie grant agreement No 699829 (ETIC).*

<img src="figs/LOGO.png" alt="ETIC" width="200px" align="left">
<img src="figs/flag_yellow_low.jpg" width="200px" align="right">
