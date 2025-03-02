# ABOUT and HOWTO tf2ss second edition

# tf2ss function returns unstable system.

Transfer function and state space model obtained by tf2ss function failed in the impulse response.

<pre>
<code>
>>
>> pkg load control; pkg load signal; clear; 
>> 
>> alpha=5.6*10^10; beta=1.2*10^10; omega=2*pi*4.1016*10^10; den1=[1 2*alpha alpha^2+omega^2]; den2=[1 2*beta beta^2+omega^2];
>> 
>> num=0.7*omega*[2*(beta-alpha) beta^2-alpha^2]; den=conv(den1, den2);
>> 
>> sys_tf=tf(num,den); figure(1); impulse(sys_tf);
error: Order numerator >= order denominator
error: called from
    imp invar at line 114 column 9
    __c2d__ at line 65 column 16
    c2d at line 87 column 7
    __time_ response__ at line 161 column 13
    impulse at line 79 column 13
>>  
>> [A,B,C,D]=tf2ss(num,den); sys_ss=ss(A,B,C,D); figure(2); impulse(sys_ss);
error: Order numerator >= order denominator
error: called from
    imp invar at line 114 column 9
    __c2d__ at line 65 column 16
    c2d at line 87 column 7
    __time_ response__ at line 161 column 13
    impulse at line 79 column 13
>>
</code>
</pre>

I checked pole and zero both sides, but pole values are the same but found zero value mismatch between sides.\
I don't know why the impulse response of transfer function doesn't behave as expected.

<table>
  <tr>
    <td style="width: 50%;">
<pre>
<code>
>> pole(sys_tf)
ans =
  -5.6000e+10 + 2.5771e+11i
  -5.6000e+10 - 2.5771e+11i
  -1.2000e+10 + 2.5771e+11i
  -1.2000e+10 - 2.5771e+11i
>> zero(sys_tf)
ans = -34000000000
</code>
</pre>
    </td>
    <td style="width: 50%;">
<pre>
<code>
>> pole(sys_ss)
ans =
  -1.2000e+10 + 2.5771e+11i
  -1.2000e+10 - 2.5771e+11i
  -5.6000e+10 + 2.5771e+11i
  -5.6000e+10 - 2.5771e+11i
>> zero(sys_ss)
ans = [](0x1)
>>
</code>
</pre>
    </td>
  </tr>
</table>

Upon review, I found that there is a problem with the calculation.\
I watched the derivation process of the equation closely and got something weird.

$$Transfer\ Function = \dfrac{b_1s + b_2}{s^4Y(s) + a_1s^3Y(s) + a_2s^2Y(s) + a_3sY(s) + a_4}$$

$Let\ x_1=Y(s)\ \to x_1'= sY(s)= x_2$\
$Let\ x_2=sY(s)\ \to x_2'=s^2Y(s)= x_3$\
$Let\ x_3=s^2Y(s) \to x_3'=s^3Y(s) = x_4$\
$Let\ x_4=s^3Y(s) \to x_4'=s^4Y(s) = -a_4 Y(s) -a_3 sY(s) -a_2 s^2Y(s) -a_1 s^3Y(s) + U(s)= -a_4 x_1 -a_3 x_2 -a_2 x_3 -a_1 x_4 + u $

There is no reason to do "Let", so I changed it as follows.

$Let\ x_1=a_3Y(s)\ \to x_1'=a_3sY(s)= \dfrac{a_3}{a_2} x_2$\
$Let\ x_2=a_2sY(s)\ \to x_2'=a_2s^2Y(s)= \dfrac{a_2}{a_1} x_3$\
$Let\ x_3=a_1s^2Y(s) \to x_3'=a_1s^3Y(s) = a_1 x_4$\
$Let\ x_4=s^3Y(s) \to x_4'=s^4Y(s) = -a_4 Y(s) -a_3 sY(s) -a_2 s^2Y(s) -a_1 s^3Y(s) + U(s)= -\dfrac{a_4}{a_3} x_1 -\dfrac{a_3}{a_2} x_2 -\dfrac{a_2}{a_1} x_3 -a_1 x_4 + u $

$$x'=\begin{bmatrix}
0 & \dfrac{a_3}{a_2} & 0 & 0\\
0 & 0 & \dfrac{a_2}{a_1} & 0\\
0 & 0 & 0 & a_1\\
-\dfrac{a_4}{a_3} & -\dfrac{a_3}{a_2} & -\dfrac{a_2}{a_1} & -a_1
\end{bmatrix} + \begin{bmatrix}
0\\
0\\
0\\
1
\end{bmatrix} u$$
$$y = \begin{bmatrix}
\dfrac{b_2}{a_3} & \dfrac{b_1}{a_2} & 0 & 0
\end{bmatrix} + 0*u$$

So I got An, Bn, Cn, Dn matrix and it works in the impulse response.

<pre>
<code>
>> a1=den(2); a2=den(3); a3=den(4); a4=den(5); b1=num(1); b2=num(2);
>> An=[0 1 0 0; 0 0 1 0; 0 0 0 a1; -a4 -a3 -a2 -a1];
>> Bn=[0 0 0 1]';
>> Cn=[b2/a3 b1/a2 0 0];
>> Dn=0;
>> 
>> sys_ssn=ss(An,Bn,Cn,Dn); figure(3); impulse(sys_ssn);
>> 
</code>
</pre>

<table>
  <tr>
    <td style="width: 50%;">
<pre>
<code>
>> pole(sys_tf)
ans =
  -5.6000e+10 + 2.5771e+11i
  -5.6000e+10 - 2.5771e+11i
  -1.2000e+10 + 2.5771e+11i
  -1.2000e+10 - 2.5771e+11i
>> zero(sys_tf)
ans = -34000000000
</code>
</pre>
    </td>
    <td style="width: 50%;">
<pre>
<code>
>> pole(sys_ssn)
ans =
  -5.6000e+10 + 2.5771e+11i
  -5.6000e+10 - 2.5771e+11i
  -1.2000e+10 + 2.5771e+11i
  -1.2000e+10 - 2.5771e+11i
>> zero(sys_ssn)
ans = -34000000000.00003
</code>
</pre>
    </td>
  </tr>
</table>

<table>
  <tr>
    <td style="width: 50%;">
<pre>
<code>
>> sys_ss
sys_ss.a =
               x1          x2          x3          x4
   x1   0.0001144  -0.0002071  -8.276e-05  -4.629e+10
   x2      -1e+11   -5.44e-05  -0.0001899   9.124e+09
   x3           0       1e+12   0.0001103   1.388e+11
   x4           0           0      -1e+12   -1.36e+11
sys_ss.b =
              u1
   x1      53.98
   x2     -158.8
   x3   1.22e-15
   x4          0
sys_ss.c =
             x1        x2        x3        x4
   y1         0         0         0   -0.0001
sys_ss.d =
       u1
   y1   0
Continuous-time model.
>></code>
</pre>
    </td>
    <td style="width: 50%;">
<pre>
<code>
>> sys_ssn
sys_ssn.a =
               x1          x2          x3          x4
   x1           0   6.573e+10           0           0
   x2           0           0   1.021e+12           0
   x3           0           0           0    1.36e+11
   x4  -5.074e+11  -6.573e+10  -1.021e+12   -1.36e+11
sys_ssn.b =
       u1
   x1   0
   x2   0
   x3   0
   x4   1
sys_ssn.c =
             x1        x2        x3        x4
   y1  -0.05916   -0.1144         0         0
sys_ssn.d =
       u1
   y1   0
Continuous-time model.
>>
</code>
</pre>
    </td>
  </tr>
</table>

Moreover, there are more zero values than the state space model obtained from the tf2ss function.

The following example works properly with both the transfer function and the state space mode.

<pre>
<code>
>> 
>> num=[0.02 2000]; den=[1 1000 132 420 2000];
>> 
>> sys_tf=tf(num,den); figure(4); impulse(sys_tf);
>> 
>> [A,B,C,D]=tf2ss(num,den); sys_ss=ss(A,B,C,D); figure(5); impulse(sys_ss);
>> 
>> An=[0 1 0 0;0 0 1 0;0 0 0 1;-a4 -a3 -a2 -a1];
>> Bn=[0 0 0 1]';
>> Cn=[b2 b1 0 0];
>> Dn=0;
>> 
>> sys_ssn=ss(An,Bn,Cn,Dn); figure(6); impulse(sys_ssn);
>>
</code>
</pre>

<table>
  <tr>
    <td style="width: 50%;">
<pre>
<code>
>> sys_ss
sys_ss.a =
               x1          x2          x3          x4
   x1   -3.44e-15   2.365e-14  -1.879e-15           2
   x2         -10   1.776e-15  -2.365e-14        -4.2
   x3           0         -10  -1.774e-15        13.2
   x4           0           0         -10       -1000
sys_ss.b =
              u1
   x1          2
   x2    -0.0002
   x3  4.729e-15
   x4          0
sys_ss.c =
       x1  x2  x3  x4
   y1   0   0   0  -1
sys_ss.d =
       u1
   y1   0
Continuous-time model.
>>
</code>
</pre>
    </td>
    <td style="width: 50%;">
<pre>
<code>
>> sys_ssn
sys_ssn.a =
           x1      x2      x3      x4
   x1       0   3.182       0       0
   x2       0       0   0.132       0
   x3       0       0       0    1000
   x4  -4.762  -3.182  -0.132   -1000
sys_ssn.b =
       u1
   x1   0
   x2   0
   x3   0
   x4   1
sys_ssn.c =
              x1         x2         x3         x4
   y1      4.762  0.0001515          0          0
sys_ssn.d =
       u1
   y1   0
Continuous-time model.
>>
</code>
</pre>
    </td>
  </tr>
</table>

But there are unwanted non-zero values in the state space model produced by the tf2ss function.

# generalization

$Let\ x_1=\boldsymbol{\alpha}Y(s)\ \to x_1'=\boldsymbol{\alpha}sY(s)= \dfrac{\boldsymbol{\alpha}}{\boldsymbol{\beta}} x_2$\
$Let\ x_2=\boldsymbol{\beta}sY(s)\ \to x_2'=\boldsymbol{\beta}s^2Y(s)= \dfrac{\boldsymbol{\beta}}{\boldsymbol{\gamma}} x_3$\
$Let\ x_3=\boldsymbol{\gamma}s^2Y(s) \to x_3'=\boldsymbol{\gamma}s^3Y(s) = \dfrac{\boldsymbol{\gamma}}{\boldsymbol{\delta}} x_4$\
$......$\
$Let\ x_{n-2}=\boldsymbol{\vartheta}s^{n-2}Y(s) \to x_{n-2}'=\boldsymbol{\vartheta}s^{n-2}Y(s)=\dfrac{\boldsymbol{\vartheta}}{\boldsymbol{\varphi}} x_n$\
$Let\ x_{n-1}=\boldsymbol{\varphi}s^{n-2}Y(s) \to x_{n-1}'=\boldsymbol{\varphi}s^{n-1}Y(s)=\boldsymbol{\varphi} x_n$\
$Let\ x_n\quad =\quad s^{n-1}Y(s) \to x_n'\quad =\quad \ \ \ \ \ s^nY(s) = -a_n Y(s) -a_{n-1} sY(s) -a_{n-2} s^2Y(s) ...-a_2 s^{n-2}Y(s) -a_1 s^{n-1}Y(s) +u(s) $
$\qquad \qquad \qquad \qquad \qquad \qquad \qquad \quad \quad \quad \quad \quad \quad = -\dfrac{\boldsymbol{\alpha}}{\boldsymbol{\beta}} a_n x_1 -\dfrac{\boldsymbol{\beta}}{\boldsymbol{\gamma}} a_{n-1} x_2 -\dfrac{\boldsymbol{\gamma}}{\boldsymbol{\delta}} a_{n-2} x_3 ...... - \dfrac{\boldsymbol{\vartheta}}{\boldsymbol{\varphi}} a_2 x_{n-1} -\boldsymbol{\varphi} a_1 x_n + u $

$$x'=\begin{bmatrix}
0 & \dfrac{\boldsymbol{\alpha}}{\boldsymbol{\beta}} & 0 & 0 & ... & 0 & 0\\
0 & 0 & \dfrac{\boldsymbol{\beta}}{\boldsymbol{\gamma}} & 0 & ... & 0 & 0\\
0 & 0 & 0 & \dfrac{\boldsymbol{\gamma}}{\boldsymbol{\delta}} & ... & 0 & 0\\
... & ... & ... & ... & ... & ... & ...\\
0 & 0 & 0 & 0 & ... & \dfrac{\boldsymbol{\vartheta}}{\boldsymbol{\varphi}} & 0\\
0 & 0 & 0 & 0 & ... & 0 & \boldsymbol{\varphi}\\
-\dfrac{\boldsymbol{\alpha}}{\boldsymbol{\beta}} a_n & -\dfrac{\boldsymbol{\beta}}{\boldsymbol{\gamma}} a_{n-1} & -\dfrac{\boldsymbol{\gamma}}{\boldsymbol{\delta}} a_{n-2} & -\dfrac{\boldsymbol{\delta}}{\boldsymbol{\epsilon}} a_{n-3} & ... & -\dfrac{\boldsymbol{\vartheta}}{\boldsymbol{\varphi}} a_2 & -\boldsymbol{\varphi} a_1
\end{bmatrix} + \begin{bmatrix}
0\\
0\\
0\\
1
\end{bmatrix} u$$
$$y = \begin{bmatrix}
\dfrac{\boldsymbol{b_n}}{\boldsymbol{\alpha}} & \dfrac{\boldsymbol{b_{n-1}}}{\boldsymbol{\beta}} & \dfrac{\boldsymbol{b_{n-2}}}{\boldsymbol{\gamma}} & \dfrac{\boldsymbol{b_{n-3}}}{\boldsymbol{\delta}} & ... & \dfrac{\boldsymbol{b_2}}{\boldsymbol{\vartheta}} & \dfrac{\boldsymbol{b_1}}{\boldsymbol{\varphi}}
\end{bmatrix} + 0*u$$

If the variables($\boldsymbol{\alpha, \beta, \gamma, \delta, \epsilon, \zeta, \eta, \theta, ..., \vartheta, \varphi}$) are modified to obtain "coefficient of the matrix = multiple of 2($2^n$)" after the continuous-to-discrete conversion,
the computational load can be reduced.

<p>$\huge{\rm{\color{#DD6565}It\ isn't\ logic\ to\ do\ "Let",\ so\ there\ is\ a\ problem\ in\ mathmatics.}}$</p>

# License
Educational Use License

This software is provided for **educational and research purposes only**.
You may use, modify, and distribute this code **only in a non-commercial
educational setting**. Any commercial use, including but not limited to
selling, licensing, or incorporating this software into commercial products,
is strictly prohibited without explicit permission from the author.

For inquiries regarding commercial use, please contact [leo92kgred@gmail.com].
