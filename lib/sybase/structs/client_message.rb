module Sybase
  # typedef struct _cs_clientmsg
  # {
  #   CS_INT          severity;
  #   CS_MSGNUM       msgnumber;
  #   CS_CHAR         msgstring[CS_MAX_MSG];
  #   CS_INT          msgstringlen;
  #   CS_INT          osnumber;
  #   CS_CHAR         osstring[CS_MAX_MSG];
  #   CS_INT          osstringlen;
  #   CS_INT          status;
  #   CS_BYTE         sqlstate[CS_SQLSTATE_SIZE];
  #   CS_INT          sqlstatelen;
  # } CS_CLIENTMSG;

  class ClientMessage < Message
    layout :severity,     :int,
           :msgnumber,    :uint,
           :msgstring,    [:char, CS_MAX_MSG],
           :msgstringlen, :int,
           :osnumber,     :int,
           :osstring,     [:char, CS_MAX_MSG],
           :osstringlen,  :int,
           :status,       :int,
           :sqlstate,     [:uchar, CS_SQLSTATE_SIZE],
           :sqlstatelen,  :int

    def text
      self[:msgstring].to_s.chomp
    end

  end # ClientMessage
end