# encoding: utf-8
require 'spec_helper'

module Graphability
  describe HtmlParser do

    class MementoMock
      def verify(domain, attribute, value)
        value
      end
    end

    let(:parser)  { HtmlParser.new  }
    let(:memento) { MementoMock.new }

    def h(head)
      html = <<-HTML
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr-FR" lang="fr-FR">
      <head>#{head}</head>
      <body></body>
      </html>
      HTML
    end

    def pa(url, html, m = nil)
      mem = m.nil? ? memento : m
      parser.parse(url, html, mem)
    end

    # Url ---------------------------------------------

    it "should return the absolute url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<link rel="canonical" href="/actu/dany.html" />'))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"

      g = pa("http://www.europe1.fr/actu/dany.html",h('<link rel="canonical" href="actu/dany.html" />'))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"
    end

    it "should return the canonical url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<link rel="canonical" href="http://www.europe2.fr/actu/toto.html" />'))
      g[:url].should eq "http://www.europe2.fr/actu/toto.html"
    end

    it "should return the og:url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<meta property="og:url" content="http://www.europe1.fr/actu/tutu.html"/>'))
      g[:url].should eq "http://www.europe1.fr/actu/tutu.html"
    end

    it "should return the twitter:url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<meta property="twitter:url" content="http://www.europe1.fr/actu/tutu.html"/>'))
      g[:url].should eq "http://www.europe1.fr/actu/tutu.html"
    end

    it "should return the best url within og:url, twitter:url and canonical" do
      meta = <<-META
      <link rel="canonical" href="http://www.europe1.fr/actu/canonical.html" />
      <meta property="og:url" content="http://www.europe1.fr/actu/og.html#xd_fragment_toto"/>
      <meta property="twitter:url" content="http://www.europe1.fr/actu/twitter.html?xtor=23"/>
      META

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:url].should eq 'http://www.europe1.fr/actu/canonical.html'

      meta = <<-META
      <link rel="canonical" href="http://www.europe1.fr/actu/canonical.html?toot=q" />
      <meta property="twitter:url" content="http://www.europe1.fr/actu/twitter.html"/>
      META

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:url].should eq 'http://www.europe1.fr/actu/twitter.html'
    end

    it "should canonize the url found" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<meta property="og:url" content="http://www.europe1.fr/actu/tutu.html?utm_source=xccff#q=34"/>'))
      g[:url].should eq "http://www.europe1.fr/actu/tutu.html"
    end

    it "should canonize the input url if no meta url found" do
      g = pa("http://www.europe1.fr/actu/dany.html", h(''))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"

      g = pa("http://www.europe1.fr/actu/dany.html?utm_source=xccff#q=34", h(''))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"
    end

    # Image ---------------------------------------------

    it "should return the og:image url" do
      g = pa("http://www.europe1.fr/actu/dany.html", h('<meta property="og:image" content="http://graphics8.nytimes.com/images/common/icons/t_wb_75.gif"/>'))
      g[:image].should eq "http://graphics8.nytimes.com/images/common/icons/t_wb_75.gif"
    end

    it "should return the twitter:image url" do
      g = pa("http://www.europe1.fr/actu/dany.html", h('<meta property="twitter:image" content="http://graphics8.nytimes.com/images/common/icons/t_wb_75.gif"/>'))
      g[:image].should eq "http://graphics8.nytimes.com/images/common/icons/t_wb_75.gif"
    end

    it "should return the rel image_src" do
      g = pa("http://www.europe1.fr/actu/dany.html", h('<link rel="image_src" href="http://graphics8.nytimes.com/images/common/icons/t_wb_75.gif" />'))
      g[:image].should eq "http://graphics8.nytimes.com/images/common/icons/t_wb_75.gif"
    end

    it "should return first og:image second twitter:image third image_src" do
      meta = <<-META
      <link rel="image_src" href="http://graphics8.nytimes.com/images/common/icons/image_src.gif" />
      <meta property="og:image" content="http://graphics8.nytimes.com/images/common/icons/og.gif"/>'
      <meta property="twitter:image" content="http://graphics8.nytimes.com/images/common/icons/twitter.gif"/>'
      META

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:image].should eq 'http://graphics8.nytimes.com/images/common/icons/og.gif'

      meta = <<-META
      <link rel="image_src" href="http://graphics8.nytimes.com/images/common/icons/image_src.gif" />
      <meta property="twitter:image" content="http://graphics8.nytimes.com/images/common/icons/twitter.gif"/>'
      META

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:image].should eq 'http://graphics8.nytimes.com/images/common/icons/twitter.gif'
    end

    it "should return nil if no image found" do
      g = pa("http://www.europe1.fr/actu/dany.html", h(''))
      g[:image].should be_nil
    end

    it "should return the verified image" do
      meta = <<-META
      <link rel="image_src" href="http://graphics8.nytimes.com/images/common/icons/image_src.gif" />
      <meta property="og:image" content="http://graphics8.nytimes.com/images/common/icons/og.gif"/>'
      <meta property="twitter:image" content="http://graphics8.nytimes.com/images/common/icons/twitter.gif"/>'
      META

      mem = double
      mem.should_receive(:verify).with("www.europe1.fr", "og:image", "http://graphics8.nytimes.com/images/common/icons/og.gif").and_return nil
      mem.should_receive(:verify).with("www.europe1.fr", "twitter:image", "http://graphics8.nytimes.com/images/common/icons/twitter.gif").and_return nil
      mem.should_receive(:verify).with("www.europe1.fr", "image_src", "http://graphics8.nytimes.com/images/common/icons/image_src.gif").and_return "http://graphics8.nytimes.com/images/common/icons/image_src.gif"

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta), mem)
      g[:image].should eq 'http://graphics8.nytimes.com/images/common/icons/image_src.gif'
    end

    it "should absolutify image url" do
      meta = <<-META
      <link rel="image_src" href="/images/common/icons/image_src.gif" />
      META
      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:image].should eq 'http://www.europe1.fr/images/common/icons/image_src.gif'
    end

    # Title ---------------------------------------------

    it "should return the og:title" do
      g = pa("http://www.toto.fr/foo.html", h('<meta property="og:title" content="UMP : Fran&ccedil;ois Baroin n\'est &quot;candidat &agrave; rien&quot;"/>'))
      g[:title].should eq "UMP : François Baroin n'est \"candidat à rien\""
    end

    it "should return the twitter:title" do
      g = pa("http://www.toto.fr/foo.html", h('<meta name="twitter:title" content="TOTO : Fran&ccedil;ois Baroin n\'est &quot;candidat &agrave; rien&quot;"/>'))
      g[:title].should eq "TOTO : François Baroin n'est \"candidat à rien\""
    end

    it "should return the html title" do
      g = pa("http://www.toto.fr/foo.html", h("<title>
            UMP : Fran&ccedil;ois Baroin n\'est &quot;candidat &agrave; rien du tout&quot;   </title>"))
      g[:title].should eq "UMP : François Baroin n'est \"candidat à rien du tout\""
    end

    it 'should return nil' do
      g = pa("http://www.toto.fr/foo.html", h(""))
      g[:title].should be_nil
    end

    it "should return the verified title" do
      mem = double
      mem.should_receive(:verify).with("www.toto.fr", "og:title", "UMP : François Baroin n'est \"candidat à rien\"").and_return nil

      g = pa("http://www.toto.fr/foo.html", h('<meta property="og:title" content="UMP : Fran&ccedil;ois Baroin n\'est &quot;candidat &agrave; rien&quot;"/>'), mem)
      g[:title].should be_nil
    end

    # Description ---------------------------------------------

    it "should return the og:description" do
      g = pa("http://www.toto.fr/foo.html", h('<meta property="og:description" content="Accus&amp;eacute; de viser la direction du parti, l\'ancien ministre d&amp;eacute;ment et enfonce Jean-Fran&amp;ccedil;ois Cop&amp;eacute;."/>'))
      g[:description].should eq "Accusé de viser la direction du parti, l'ancien ministre dément et enfonce Jean-François Copé."
    end

    it "should not return an empty string" do
      g = pa("http://www.toto.fr/foo.html", h('<meta property="og:description" content=""/>'))
      g[:description].should be_nil
    end

    it "should return a different desc than title" do
      meta = <<-META
      <meta property="og:title" content="my toto title"/>
      <meta property="og:description" content="my toto title"/>
      <meta property="twitter:description" content="my unique desc"/>
      META

      g = pa("http://www.toto.fr/foo.html", meta)
      g[:description].should eq "my unique desc"
    end

    it "should return the twitter:description" do
      g = pa("http://www.toto.fr/foo.html", h('<meta property="twitter:description" content="Accus&amp;eacute; de viser la direction du parti, l\'ancien ministre d&amp;eacute;ment et enfonce Jean-Fran&amp;ccedil;ois Cop&amp;eacute;."/>'))
      g[:description].should eq "Accusé de viser la direction du parti, l'ancien ministre dément et enfonce Jean-François Copé."
    end

    it "should return the meta description" do
      g = pa("http://www.toto.fr/foo.html", h('<meta name="Description" content="Le cerveau d&#8217;un millier de seniors st&#233;phanois est &#233;tudi&#233; depuis une d&#233;cennie au CHU. Des r&#233;sultats &#233;tonnants !" />'))
      g[:description].should eq 'Le cerveau d’un millier de seniors stéphanois est étudié depuis une décennie au CHU. Des résultats étonnants !'
    end

    it "should return nil" do
      g = pa("http://www.toto.fr/foo.html", h(''))
      g[:description].should be_nil
    end

    it "should return the verified description" do
      mem = double
      mem.should_receive(:verify).and_return nil

      g = pa("http://www.toto.fr/foo.html", h('<meta property="og:description" content="Accus&amp;eacute; de viser la direction du parti, l\'ancien ministre d&amp;eacute;ment et enfonce Jean-Fran&amp;ccedil;ois Cop&amp;eacute;."/>'), mem)
      g[:description].should be_nil
    end

    # Published at ---------------------------------------------

    it "should return the open graph article:published_time" do
      g = pa("http://www.toto.fr/foo.html", h('<meta property="article:published_time" content="2012-12-14T00:00:00+0100">'))
      g[:published_at].should eq 1355439600
    end

    it "should return nil" do
      g = pa("http://www.toto.fr/foo.html", h(''))
      g[:published_at].should be_nil
    end
  end
end