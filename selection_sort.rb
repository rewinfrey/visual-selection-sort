require 'rubygems'
require 'sinatra'
require 'coffee-script'

get '/' do
  erb :selection_sort
end