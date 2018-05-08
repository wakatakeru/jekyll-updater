require 'dotenv'
require 'sinatra'
require 'open3'

Dotenv.load

post '/' do
  request.body.rewind
  payload_body = request.body.read
  verify_signature(payload_body)
  push = JSON.parse(params[:payload])
  update_repo if master_merged?(push)
end

def verify_signature(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), ENV['SECRET_TOKEN'], payload_body)
  return halt 500, "Signatures didn't match!" unless Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
end

def master_merged?(push)
  action = push['action']
  ref = push['pull_request']['base']['ref']
  merged = push['pull_request']['merged']

  return true if action == 'closed' && ref == 'master' && merged == true
  return false
end

def update_repo
  jekyll_root = ENV['JEKYLL_ROOT'].chomp

  Dir.chdir(jekyll_root) do
    `git checkout master`
    `git pull origin master`
  end
end
