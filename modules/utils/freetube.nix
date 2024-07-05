{ config
, ...
}:
{
  config = {
    programs.freetube.enable = true;
    programs.freetube.settings = {
      allSettingsSectionsExpandedByDefault = true;
      barColor = false;
      baseTheme = "dark";
      checkForBlogPosts = false;
      checkForUpdates = false;
      commentAutoLoadEnabled = false;
      currentLocale = "pl";
      downloadBehavior = "open";
      hideActiveSubscriptions = false;
      hideChannelPlaylists = false;
      hideChannelShorts = false;
      hideCommentLikes = true;
      hideCommentPhotos = true;
      hideComments = true;
      hideHeaderLogo = true;
      hideLabelsSideBar = true;
      hideLiveChat = true;
      hidePlaylists = false;
      hidePopularVideos = true;
      hideSubscriptionsCommunity = true;
      hideSubscriptionsLive = true;
      hideSubscriptionsShorts = false;
      hideTrendingVideos = true;
      hideVideoLikesAndDislikes = true;
      mainColor = "Orange";
      secColor = "Orange";
      useProxy = false;
      useSponsorBlock = false;
    };
  };
}
