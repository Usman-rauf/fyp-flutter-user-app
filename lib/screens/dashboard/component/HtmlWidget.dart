import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../screens/dashboard/component/VimeoEmbedWidget.dart';
import '../../../screens/dashboard/component/YouTubeEmbedWidget.dart';
import '../../../utils/CachedNetworkImage.dart';
import '../../../utils/common.dart';

class HtmlWidget extends StatelessWidget {
  final String postContent;
  final Color color;

  HtmlWidget({this.postContent, this.color});

  @override
  Widget build(BuildContext context) {
    return Html(
      data: postContent,
      onLinkTap: (s, _, __, ___) {
          appLaunchUrl(s, forceWebView: true);
      },
      onImageTap: (s, _, __, ___) {
        // openPhotoViewer(context, Image.network(s).image);
      },
      style: {
        "table": Style(backgroundColor: color ?? transparentColor),
        "tr": Style(border: Border(bottom: BorderSide(color: Colors.black45.withOpacity(0.5)))),
        "th": Style(padding: EdgeInsets.all(6), backgroundColor: Colors.black45.withOpacity(0.5)),
        "td": Style(padding: EdgeInsets.all(6), alignment: Alignment.center),
        'embed': Style(color: color ?? transparentColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: FontSize(16)),
        'strong': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'a': Style(color: color ?? Colors.blue, fontWeight: FontWeight.bold, fontSize: FontSize(16)),
        'div': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'figure': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16), padding: EdgeInsets.zero, margin: EdgeInsets.zero),
        'h1': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'h2': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'h3': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'h4': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'h5': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'h6': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'ol': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'ul': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'strike': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'u': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'b': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'i': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'hr': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'header': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'code': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'data': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'body': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'big': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'blockquote': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'audio': Style(color: color ?? textPrimaryColorGlobal, fontSize: FontSize(16)),
        'img': Style(width: context.width(), padding: EdgeInsets.only(bottom: 8), fontSize: FontSize(16)),
        'li': Style(
          color: color ?? textPrimaryColorGlobal,
          fontSize: FontSize(16),
          listStyleType: ListStyleType.DISC,
          listStylePosition: ListStylePosition.OUTSIDE,
        ),
      },
      customRender: {
        "embed": (RenderContext renderContext, Widget child) {
          var videoLink = renderContext.parser.htmlData.text.splitBetween('<embed>', '</embed');

          if (videoLink.contains('yout')) {
            return YouTubeEmbedWidget(videoLink.replaceAll('<br>', '').toYouTubeId());
          } else if (videoLink.contains('vimeo')) {
            return VimeoEmbedWidget(videoLink.replaceAll('<br>', ''));
          } else {
            return child;
          }
        },
        "figure": (RenderContext renderContext, Widget child) {
          if (renderContext.tree.element.innerHtml.contains('yout')) {
            return YouTubeEmbedWidget(renderContext.tree.element.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').toYouTubeId());
          } else if (renderContext.tree.element.innerHtml.contains('vimeo')) {
            return VimeoEmbedWidget(renderContext.tree.element.innerHtml.splitBetween('<div class="wp-block-embed__wrapper">', "</div>").replaceAll('<br>', '').splitAfter('com/'));
          } else if (renderContext.tree.element.innerHtml.contains('audio')) {
            //return AudioPostWidget(postString: renderContext.tree.element.innerHtml);
          } else {
            return child;
          }
        },
        "iframe": (RenderContext renderContext, Widget child) {
          return YouTubeEmbedWidget(renderContext.tree.attributes['src'].toYouTubeId());
        },
        "img": (RenderContext renderContext, Widget child) {
          String img = '';
          if (renderContext.tree.attributes.containsKey('src')) {
            img = renderContext.tree.attributes['src'];
          } else if (renderContext.tree.attributes.containsKey('data-src')) {
            img = renderContext.tree.attributes['data-src'];
          }
          return cachedImage(img).cornerRadiusWithClipRRect(defaultRadius).onTap(() {
            // openPhotoViewer(context, NetworkImage(img));
          });
        },
        "blockquote": (RenderContext renderContext, Widget child) {
          // return TweetWebView(tweetUrl: renderContext.tree.element.outerHtml);
        },
        "table": (RenderContext renderContext, Widget child) {
          return Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.open_in_full_rounded),
                  onPressed: () async {
                    setOrientationPortrait();
                  },
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: (renderContext.tree as TableLayoutElement).toWidget(renderContext),
              ),
            ],
          );
        },
      },
    );
  }
}

