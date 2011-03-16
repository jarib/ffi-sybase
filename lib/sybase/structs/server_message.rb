module Sybase
  # typedef struct _cs_servermsg
  # {
  #   CS_MSGNUM msgnumber;
  #   CS_INT            state;
  #   CS_INT            severity;
  #   CS_CHAR           text[CS_MAX_MSG];
  #   CS_INT            textlen;
  #   CS_CHAR           svrname[CS_MAX_CHAR];
  #   CS_INT            svrnlen;
  #   CS_CHAR           proc[CS_MAX_CHAR];
  #   CS_INT            proclen;
  #   CS_INT            line;
  #   CS_INT            status;
  #   CS_BYTE           sqlstate[CS_SQLSTATE_SIZE];
  #   CS_INT            sqlstatelen;
  # } CS_SERVERMSG;

  class ServerMessage < Message
    layout :msgnumber,   :uint,
           :state,       :int,
           :severity,    :int,
           :text,        [:char, CS_MAX_MSG],
           :textlen,     :int,
           :svrname,     [:char, CS_MAX_CHAR],
           :svrnlen,     :int,
           :proc,        [:char, CS_MAX_CHAR],
           :proclen,     :int,
           :line,        :int,
           :status,      :int,
           :sqlstate,    [:uchar, CS_SQLSTATE_SIZE],
           :sqlstatelen, :int

    def text
      self[:text].to_s.chomp
    end
  end
end