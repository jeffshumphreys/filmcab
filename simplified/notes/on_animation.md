<#

https://www.systanddeploy.com/2019/11/powershell-and-wpf-how-to-use-animated.html

https://github.com/XamlAnimatedGif/WpfAnimatedGif
A simple library to display animated GIF images in WPF, usable in XAML or in code.
var image = new BitmapImage();
image.BeginInit();
image.UriSource = new Uri(fileName);
image.EndInit();
ImageBehavior.SetAnimatedSource(img, image);
https://www.nuget.org/packages/WpfAnimatedGif

#>

<#


https://stackoverflow.com/questions/165735/how-do-you-show-animated-gifs-on-a-windows-form-c
  private void button1_Click(object sender, EventArgs e)
  {
   ThreadStart myThreadStart = new ThreadStart(Show);
   Thread myThread = new Thread(myThreadStart);
   myThread.Start();
  }

Show activity on this post.

Note that in Windows, you traditionally don't use animated Gifs, but little AVI animations: there is a Windows native control just to display them. There are even tools to convert animated Gifs to AVI (and vice-versa).

https://learn.microsoft.com/en-us/windows/win32/controls/animation-control-overview


https://learn.microsoft.com/en-us/dotnet/api/system.windows.media.animation.animatable?view=windowsdesktop-8.0

Animatable Class
System.Windows.Media.Animation
public abstract class Animatable : System.Windows.Freezable, System.Windows.Media.Animation.IAnimatable

CAnimateCtrl m_avi;this is placed in your .h file.
https://www.codeproject.com/Articles/159/CAnimateCtrl-Example

Function ShowProgressGifDelegate {
    $animatedGif.Visible = $true
}
Function ShowAnimation()
{
 $this.Invoke(ShowProgressGifDelegate);
 #//your long running process
 #System.Threading.Thread.Sleep(5000);
 #this.Invoke(this.HideProgressGifDelegate);