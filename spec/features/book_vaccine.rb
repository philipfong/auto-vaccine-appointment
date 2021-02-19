require 'spec_helper'

NUM_LOCATIONS = 3
BDAY = '01011970' # MMDDYYYY
ZIP = '11373'
FIRST = 'Anthony'
LAST = 'Fauci'
ADDR = '79-01 Broadway'
CITY = 'Elmhurst'
COUNTY = 'Queens'
STATE = 'New York'
PHONE = '7185551234'
EMAIL = 'drfauci@nih.gov'

feature "Book Covid-19 appointment on NYS website" do

  scenario "Complete booking" do
    complete_prescreen
    click_button 'Locate Providers'
    wait_for_appointment
    select_time
    continue_appointment
    complete_screening
  end

end

def complete_prescreen
  visit 'https://am-i-eligible.covid19vaccine.health.ny.gov/'
  page.should have_text 'Last updated'
  click_button 'Get Started'
  find('[placeholder="MM/DD/YYYY"]').set(BDAY)
  find('[aria-labelledby="gender_group_label"]').all('.ux-radio').last.click # Sex: Prefer not to answer
  find('[aria-labelledby="nyresident_label"]').first('div').click # Yes
  find('[aria-labelledby="nyworker_label"]').first('div').click # Yes
  find('#zip').set(ZIP)
  find('[aria-labelledby="underlyingCondition_label"]').first('div').click # Yes
  find('[aria-labelledby="underlyingConditionConfirm_label"]').first('div').click # Yes
  all('.ux-row')[5].click # I consent
  click_button 'Submit'
  page.should have_text 'Based on what you have told us, you are eligible to receive a vaccine.'
end

def wait_for_appointment
  found = false
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
      click_button 'Update'
      sleep 10 # Wait a little before refresh
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
  end
end

def complete_screening
  within_window @win do
    completed = false
    while !completed
      find('input[value="N"]').click
      click_button 'Next'
      sleep 1 # It's just easier to do this
      if page.has_text?('I have read the entire list of priority groups', :wait => 1)
        find('input[value="Y"]').click
        completed = true
      end
    end
    click_button 'Next'
    page.should have_text 'Thank you'
    click_button 'Continue'
    page.should have_text 'Review your Information'
    click_button 'Register'
    Log.info 'Registration should have completed'
    sleep 10 # I'm not sure what the page looks at this end step, so sleep and take screenshot
    page.save_screenshot
  end
end
