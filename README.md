# auto-vaccine-appointment
Automatically searches for and completes booking of Covid-19 vaccination appointment. New York State only.

### How does this work? ###

This script opens a Chrome browser, waits for appointments to open up, and once available will select a random time slot and complete the entire booking process automatically.

Update (3/30/2021): This script is a lot less effective now that many of the vaccination sites have implemented captchas (while strangely, others have not like the J&J Javitz Center appointments). I've implemented some quick & hacky code in scenario #1 of the feature spec that will assist with page refreshes there.

### Installation ###

1. Install a Ruby version manager such as rbenv or rvm (on Windows, check out https://rubyinstaller.org/)
2. Clone the repo
3. `gem install bundler`
4. `bundle install`

### Running ###

1. There are a bunch of constants at the top of the file named `book_vaccine.rb`. Update those to reflect your own personal information.
2. `rspec spec/features/book_vaccine.rb > booking.log`
3. Wait forever because appointment slots never seem to open up anyway, unless you're in Potsdam, NY.

Here it is in action:

![](https://thumbs.gfycat.com/EuphoricSolidGyrfalcon-size_restricted.gif)
