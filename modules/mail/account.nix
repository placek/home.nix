let
  notmuchTag = notmuch: tag: criteria: "${notmuch}/bin/notmuch tag ${tag} -- '${criteria}'";
  details = { pass , name , identity , email , isPrimary ? false }: {
    primary = isPrimary;
    address = email;
    userName = email;
    realName = name;
    passwordCommand = "${pass}/bin/pass MAIL/${email}";
    imap.host = "imap.gmail.com";
    smtp.host = "smtp.gmail.com";
    mbsync.enable = true;
    mbsync.create = "both";
    mbsync.expunge = "both";
    mbsync.patterns = [ "*" "![Gmail]*" "[Gmail]/Sent Mail" "[Gmail]/Starred" "[Gmail]/All Mail" ];
    mbsync.extraConfig.channel.Sync = "All";
    mbsync.extraConfig.account.Timeout = 120;
    mbsync.extraConfig.account.PipelineDepth = 1;
    notmuch.enable = true;
    msmtp.enable = true;
  };

  notmuchSteps = notmuch: identity: email: ''
    ${notmuchTag notmuch "+account:${identity}" "path:${identity}/**"}
    ${notmuchTag notmuch "+account:${identity}" "to:${email} OR from:${email}"}
  '';

  notmuchStripInbox = notmuch: identities:
    notmuchTag notmuch "-Inbox" (builtins.foldl' (acc: item: "${acc} AND ${item}") "true" (
      builtins.map (identity: "not folder:${identity}/Inbox") identities
    ));
in
{ inherit details notmuchTag notmuchSteps notmuchStripInbox; }
