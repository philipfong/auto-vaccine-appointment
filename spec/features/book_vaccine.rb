require 'spec_helper'

PREFERRED_LOCATION = 'NONE' # Or specify a location like 'JAVITS CENTER'
NUM_LOCATIONS = 3 # If no preferred location, find appts at top 3 results
REFRESH_INTERVAL = 10 # In seconds
BDAY = '01011970' # MMDDYYYY
ZIP = '11373'
FIRST = 'Anthony'
LAST = 'Fauci'
ADDR = '79-01 Broadway'
CITY = 'Elmhurst'
COUNTY = 'Queens' # Other option I've seen available is 'Nassau'
STATE = 'New York'
PHONE = '7185551234'
EMAIL = 'drfauci@nih.gov'

feature "Book Covid-19 appointment on NYS website" do

  scenario "Refresh page for J&J vaccine" do # Legitimately worked on 3/30, when eligibility opened up. No captcha on this page for some reason.
    visit 'https://am-i-eligible.covid19vaccine.health.ny.gov/'
    sleep 60 # Complete form here
    section = find('div h4', :text => 'JAVITS CENTER ( 26.9 MILES ) VACCINE TYPE: JANSSEN – J & J').find(:xpath, '../../..')
    @win = window_opened_by do
      section.click_link 'Schedule your vaccine appointment'
    end
    found = false
    within_window @win do
      sleep 10
      while !found
        if page.has_text?('No Appointments Available', :wait => 1)
          page.refresh
        else
          Log.info 'FOUND SOMETHING'
          sleep 10000
        end
      end
    end
  end

  scenario "Complete booking" do
    begin
      complete_prescreen
      click_button 'Locate Providers'
      wait_for_appointment
      select_time
      continue_appointment
      complete_screening
    rescue RSpec::Expectations::ExpectationNotMetError => e
      Log.error 'Something went wrong in RSpec exepctations. Error was: %s' % e
      retry
    rescue Capybara::ElementNotFound => e
      Log.error 'Something went wrong in Capybara finder. Error was: %s' % e
      retry
    end
  end

end

def complete_prescreen
  visit 'https://am-i-eligible.covid19vaccine.health.ny.gov/'
  page.should have_text 'Last updated'
  click_button 'Get Started'
  find('[placeholder="MM/DD/YYYY"]').set(BDAY)
  find('[aria-labelledby="gender_group_label"]').all('.ux-radio').last.click # Sex: Prefer not to answer
  find('[aria-labelledby="nyresident_label"]').first('div').click # Yes, live in NY
  find('[aria-labelledby="nyworker_label"]').first('div').click # Yes, work in NY
  find('#zip').set(ZIP)
  if page.has_text?('Additional Information', :wait => 2) # Shows up if under 65 years of age
    find('[aria-labelledby="underlyingCondition_label"]').first('div').click # Yes, I have health issues
    find('[aria-labelledby="underlyingConditionConfirm_label"]').first('div').click # Yes, I have one of the things
  end
  find('.ux-row', :text => 'I consent').click # I consent
  click_button 'Submit'
  page.should have_text 'Based on what you have told us, you are eligible to receive a vaccine.'
  Log.info 'Prescreen completed.'
end

def wait_for_appointment
  found = false
  if PREFERRED_LOCATION != 'NONE'
    section = find('div h4', :text => PREFERRED_LOCATION.upcase).find(:xpath, '../../..')
    @win = window_opened_by do
      section.click_link 'Schedule your vaccine appointment'
    end
    while !found
      within_window @win do
        page.should have_text 'Department of Health'
        if page.has_no_text?('No Appointments Available', :wait => 2)
          Log.info 'FOUND APPOINTMENT AT %s!' % PREFERRED_LOCATION.upcase
          found = true
        else
          Log.info 'No appointments found at %s' % PREFERRED_LOCATION.upcase
          sleep REFRESH_INTERVAL
          page.refresh
        end
      end
    end
  else
    while !found
      (0..NUM_LOCATIONS-1).each do |num|
        section_css_id = '#section_%s' % num
        section_name = find(section_css_id).find(:xpath, '..').find('h4').text
        if find(section_css_id).has_no_text?('No Appointments Available Currently', :wait => 1)
          found = true
          Log.info 'FOUND APPOINTMENT AT %s!' % section_name
          @win = window_opened_by do
            find(section_css_id).click_link 'Schedule your vaccine appointment'
          end
          break
        else
          Log.info 'No appointments found at %s' % section_name
        end
      end
      if found == false
        sleep REFRESH_INTERVAL
        click_button 'Update'
      end
    end
  end
end

def select_time
  within_window @win do
    click_button 'Select Visit Time'
    page.should have_text 'Please select the preferred time period'
    selected = false
    while !selected
      all('[type="radio"]').sample.click # Click random available appointment
      click_button 'Next'
      if page.has_text?('Enter Recipient Information for the Event', :wait => 1)
        selected = true
      else
        page.should have_text 'The time slot you have selected has been taken. Please select a new time slot from below.'
      end
    end
  end
  Log.info 'Timeslot selected.'
end

def continue_appointment
  within_window @win do
    fill_in('First Name', :with => FIRST)
    fill_in('Last Name', :with => LAST)
    find('#address').set(ADDR)
    find('#addrZip').set(ZIP)
    find('#addrCity').set(CITY)
    find('#countyID').select(COUNTY)
    find('#addrState').select(STATE)
    find('#phone').set(PHONE)
    find('#phoneConfirm').set(PHONE)
    find('#emailAddress').set(EMAIL)
    find('#emailAddressConfirm').set(EMAIL)
    find('#datepicker').set(BDAY)
    click_button 'Next'
    page.should have_text 'Enter Patient Demographics Information'
    select('No Response', :from => 'Race')
    select('No Response', :from => 'Ethnicity')
    click_button 'Next'
    page.should have_text 'Enter On-Site Requirements'
    select('Personally, Owned Vehicle', :from => 'transportationID')
    select('No', :from => 'needHandicapAccessID')
    select('No', :from => 'needLanguageAssistanceID')
    click_button 'Next'
    page.should have_text 'Enter Emergency Contact Information'
    click_button 'Next'
    page.should have_text 'Insurance Information'
    find('#patientInsured').select('No')
    find('#patientInsuredConsent').click
    find('#privacyPolicyReceived').click
    click_button 'Next'
    page.should have_text 'Enter Primary Care Provider'
    click_button 'Next'
    page.should have_text 'Screening Questions'
    Log.info 'Personal information completed.'
  end
end

def complete_screening
  within_window @win do
    completed = false
    while !completed
      find('input[value="N"]').click
      click_button 'Next'
      sleep 0.25 # It's just easier to do this
      if page.has_text?('I have read the entire list of priority groups', :wait => 0.25)
        find('input[value="Y"]').click
        completed = true
      end
    end
    click_button 'Next'
    page.should have_text 'Thank you'
    click_button 'Continue'
    page.should have_text 'Review your Information'
    click_button 'Register'
    Log.info 'Registration should have completed, we have just clicked "Register".'
    page.should have_text 'Appointment Confirmation'
    Log.info 'Congratulations. Your appointment has been booked.'
    page.save_screenshot
  end
end
