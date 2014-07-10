require 'sinatra'
require 'haml'
require 'json'
require 'open-uri'

enable :inline_templates

get '/' do
  haml :index, :format => :html5
end

post '/' do
  if params[:str].nil?
    @message = "URLかキャラクターIDを入力してください"
  elsif /http:\/\/lhrpg\.com\/lhz\/pc\?id=(\d+)/ =~ params[:str]
    @user_input = params[:str]
    @chara_id = $1
  elsif /\d+/ =~ params[:str]
    @chara_id = @user_input = params[:str]
  else
    @message = "URLかキャラクターIDを入力してください"
  end
  @iframe_url = "#{request.base_url}/chara/#{@chara_id}"
  haml :post, :format => :html5
end

get '/chara/:id' do
  begin
    @json = JSON.parse(open("http://lhrpg.com/lhz/api/#{params[:id]}.json").read)
  rescue OpenURI::HTTPError => ex
    case ex.io.status[0]
    when "404"
      @message = "そのURLもしくはキャラクターIDはアクセスが許可されてません"
    end
  end
  haml :chara, :format => :html5
end

__END__

@@ layout
%html
  = yield

@@ index
%html
  %head
    %meta{ :content=>"text/html", :charset=>"utf-8" }
    %title LHZキャラクターブログパーツ生成器
  %body
    #main
      %h1 LHZキャラクターブログパーツ生成器
      %div 機能を設定したキャラクターのURL、キャラIDを入力してください
      %form{:action=>"/", :method=>"post"}
        %input{:type=>"texfield",:name=>"str",:value=> @user_input.nil? ? "3476" : @user_input}
        %input{:type=>"submit", :value=>"send"}
      %div= @message

@@ post
%html
  %head
    %meta{ :content=>"text/html", :charset=>"utf-8" }
    %title LHZキャラクターブログパーツ生成器
  %body
    #main
      %h1 LHZキャラクターブログパーツ生成器
      %div 機能を設定したキャラクターのURL、キャラIDを入力してください
      %form{:action=>"/", :method=>"post"}
        %input{:type=>"texfield",:name=>"str",:value=> @user_input.nil? ? "3476" : @user_input}
        %input{:type=>"submit", :value=>"send"}
      %iframe{:src=>@iframe_url, :scrolling => "no"}
      %br
      #iframe_tag
        このキャラのiframeタグ:
        %input{:type=>"texfield", :name=>"iframe", :value =>"<iframe src=\"#{@iframe_url}\" scrolling=\"no\" />"}

@@ chara
%html
  %head
    %meta{ :content=>"text/html", :charset=>"utf-8" }
    %title= @json['name'] 
  %body{ :style=>"background-image : url('http://lhrpg.com/lhz/css/bg.jpg');margin:0"}
    %div(style="background-color:#3F2717")
      %a(target="_blank" href="http://lhrpg.com/lhz/top")
        %img(src="http://lhrpg.com/lhz/image/head_logo.png" height="20px")
    %div(style="text-align:left")
      %div(style="float:right")
        %a(target="_blank" href="#{@json['sheet_url']}")= @json['name']
        - text1="#{@json['race']} / #{@json['archetype']}"
        - text2="#{@json['main_job']} / #{@json['sub_job']}"
        %p= text1 
        %p= text2 
        %p(align="right" style="font-size:10")= @json['player_name']
      %a(target="_blank" href="#{@json['sheet_url']}")
        %img(width="110px" src="#{@json['image_url']}" text="#{@json['name']}")
