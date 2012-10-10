# encoding: utf-8
require 'spec_helper'

module Graphability
  describe HtmlParser do

    let(:parser) { HtmlParser.new }

    def h(head)
      html = <<-HTML
      <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
      <html xmlns="http://www.w3.org/1999/xhtml" xml:lang="fr-FR" lang="fr-FR">
      <head>#{head}</head>
      <body></body>
      </html>
      HTML
    end

    def pa(url,html)
      parser.parse(url, html)
    end

    it "should return the absolute url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<link rel="canonical" href="/actu/dany.html" />'))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"

      g = pa("http://www.europe1.fr/actu/dany.html",h('<link rel="canonical" href="actu/dany.html" />'))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"
    end

    it "should return the canonical url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<link rel="canonical" href="http://www.europe1.fr/actu/toto.html" />'))
      g[:url].should eq "http://www.europe1.fr/actu/toto.html"
    end

    it "should return the og:url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<meta property="og:url" content="http://www.europe1.fr/actu/tutu.html"/>'))
      g[:url].should eq "http://www.europe1.fr/actu/tutu.html"
    end

    it "should return the twitter:url" do
      g = pa("http://www.europe1.fr/actu/dany.html",h('<meta property="twitter:url" content="http://www.europe1.fr/actu/tutu.html"/>'))
      g[:url].should eq "http://www.europe1.fr/actu/tutu.html"
    end

    it "should return first og:url second twitter:url third canonical" do
      meta = <<-META
      <link rel="canonical" href="http://www.europe1.fr/actu/canonical.html" />
      <meta property="og:url" content="http://www.europe1.fr/actu/og.html"/>
      <meta property="twitter:url" content="http://www.europe1.fr/actu/twitter.html"/>
      META

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:url].should eq 'http://www.europe1.fr/actu/og.html'

      meta = <<-META
      <link rel="canonical" href="http://www.europe1.fr/actu/canonical.html" />
      <meta property="twitter:url" content="http://www.europe1.fr/actu/twitter.html"/>
      META

      g = pa("http://www.europe1.fr/actu/dany.html", h(meta))
      g[:url].should eq 'http://www.europe1.fr/actu/twitter.html'
    end

    it "should canonize the input url if no meta url found" do
      g = pa("http://www.europe1.fr/actu/dany.html", h(''))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"

      g = pa("http://www.europe1.fr/actu/dany.html?utm_source=xccff#q=34", h(''))
      g[:url].should eq "http://www.europe1.fr/actu/dany.html"
    end

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

  end
end