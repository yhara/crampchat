require 'cramp/controller'
require 'usher'
require 'erb'
require 'tilt'

=begin
Pages:
  http://server/ : show chat page

APIs:
  http://server/listen : start listening message
    returns string (maybe after long time)
  http://server/say?message=str : post message
=end

module Chat
  @messages = []
  def self.messages; @messages; end

  class MainPage < Cramp::Controller::Action
    @template = Tilt.new('views/index.erb')
    def self.template; @template; end

    def start
      render MainPage.template.render
      finish
    end
  end

  class WaitMessage < Cramp::Controller::Action
    def start
      Chat.waitMessage{|msg| send_message(msg)}
    end

    def send_message(msg)
      render msg.inspect + "\n"
      finish
    end
  end

  class PostMessage < Cramp::Controller::Action
    def start
      Chat.messages << @env['usher.params'][:message]
      render "ok"
      finish
    end
  end

  class StaticFiles < Cramp::Controller::Action
    def start
      render File.read("public/jquery.js")
      finish
    end
  end

end

routes = Usher::Interface.for(:rack) do
  add('/').to(Chat::MainPage)
  add('/listen').to(Chat::WaitMessage)
  add('/say').to(Chat::PostMessage)

  add('/jquery.js').to(Chat::StaticFiles)
end

Rack::Handler::Thin.run routes, :Port => 3000

