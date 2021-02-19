# auto-vaccine-appointment
Automatically searches for and completes booking of Covid-19 vaccination appointment. New York State only.

### How does this work? ###

This script opens a Chrome browser, waits for appointments to open up, and once available with select a random time slot and complete the entire booking process automatically.

### Installation ###

1. Install a Ruby version manager such as rbenv or rvm (on Windows, check out https://rubyinstaller.org/)
2. Clone the repo
3. `gem install bundler`
4. `bundle install`

### Running ###

1. There are a bunch of constants at the top of the file named `book_vaccine.rb`. Update those to reflect your own personal information.
2. `rspec spec/features/book_vaccine.rb`
3. Wait forever because appointment slots never seem to open up anyway, unless you're in Potsdam, NY.
