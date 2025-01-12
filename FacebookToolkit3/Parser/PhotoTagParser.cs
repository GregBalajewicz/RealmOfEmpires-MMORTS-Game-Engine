using System;
using System.Xml;
using Facebook.Entity;
using Facebook.Utility;

namespace Facebook.Parser {
    internal sealed class PhotoTagParser
    {
        /// <summary>
        /// Default constructor
        /// </summary>
        private PhotoTagParser() { }

        /// <summary>
        /// Uses DOM parsing to constitute a PhotoTag data object given the xml returned from facebook
        /// </summary>
        internal static PhotoTag ParsePhotoTag(XmlNode node)
        {
            PhotoTag photoTag = new PhotoTag();
            if (node != null)
            {
                photoTag.PhotoId = XmlHelper.GetNodeText(node, "pid");
                photoTag.SubjectUserId = XmlHelper.GetNodeText(node, "subject");

                Double tempDouble;
#if NETCF
                try
                {
                    tempDouble = double.Parse(XmlHelper.GetNodeText(node, "xcoord"));
                    photoTag.XCoord = tempDouble;
                }
                catch
                {
                }
                try
                {
                    tempDouble = double.Parse(XmlHelper.GetNodeText(node, "ycoord"));
                    photoTag.YCoord = tempDouble;
                }
                catch
                {
                }
#else
                if(Double.TryParse(XmlHelper.GetNodeText(node, "xcoord"), out tempDouble))
                {
                    photoTag.XCoord = tempDouble;
                }
                if(Double.TryParse(XmlHelper.GetNodeText(node, "ycoord"), out tempDouble))
                {
                    photoTag.YCoord = tempDouble;
                }
#endif
            }
            return photoTag;
        }
    }
}