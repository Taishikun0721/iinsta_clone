puts "start to create posts...."
User.limit(10).each do |user|
  post = user.posts.create(
      body: Faker::Movies::BackToTheFuture.quote,
      remote_images_urls: %w[https://placeimg.com/350/350/any https://placeimg.com/350/350/any]
  )
  puts "post#{post.id} is successfully created!!!"
end