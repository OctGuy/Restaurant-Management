using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;
using System.Drawing.Imaging;
using System.Windows.Media.Imaging;
using System.IO;

namespace RestaurantManagement
{
    public class ImageConverter
    {
        // Convert from var binary to bitmap
        public BitmapImage ByteArrayToBitmapImage(byte[] imageData)
        {
            using (var ms = new MemoryStream(imageData))
            {
                BitmapImage bitmap = new BitmapImage();
                bitmap.BeginInit();
                bitmap.StreamSource = ms;
                bitmap.CacheOption = BitmapCacheOption.OnLoad; // Tải toàn bộ dữ liệu vào bộ nhớ
                bitmap.EndInit();
                bitmap.Freeze(); // Đảm bảo đối tượng an toàn khi sử dụng sau khi stream bị dispose
                return bitmap;
            }
        }

        // Convert bitmap to var binary
        public byte[] BitmapImageToByteArray(string imagePath)
        {
            return File.ReadAllBytes(imagePath);
        }
    }
}
