puts "start to create users...."
10.times do
  user = User.create(
      username: Faker::Movies::BackToTheFuture.character,
      email: Faker::Internet.email,
      password: 'password',
      password_confirmation: 'password',
  )
  puts "#{user.username} is successfully created!!"
end