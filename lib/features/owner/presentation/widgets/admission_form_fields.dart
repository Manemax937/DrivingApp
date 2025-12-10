import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/utils/validators.dart';

class AdmissionFormFields {
  // Personal Information Fields
  static Widget buildFullNameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Full Name (as per ID) *',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      validator: Validators.validateName,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildFatherNameField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Father / Guardian Name',
        prefixIcon: Icon(Icons.family_restroom),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildPhoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Mobile Number *',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
        counterText: '',
      ),
      keyboardType: TextInputType.phone,
      validator: Validators.validatePhone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildAlternatePhoneField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Alternate Phone',
        prefixIcon: Icon(Icons.phone_android),
        border: OutlineInputBorder(),
        counterText: '',
      ),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildEmailField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Email (optional)',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
      textInputAction: TextInputAction.next,
    );
  }

  // Address Fields
  static Widget buildAddressField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Full Address',
        prefixIcon: Icon(Icons.home),
        border: OutlineInputBorder(),
      ),
      maxLines: 2,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildCityField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'City',
        prefixIcon: Icon(Icons.location_city),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildPincodeField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Pincode',
        border: OutlineInputBorder(),
        counterText: '',
      ),
      keyboardType: TextInputType.number,
      validator: Validators.validatePincode,
      maxLength: 6,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
    );
  }

  // Dropdown Fields
  static Widget buildGenderDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Gender',
        border: OutlineInputBorder(),
      ),
      items: ['Male', 'Female', 'Other'].map((gender) {
        return DropdownMenuItem(value: gender, child: Text(gender));
      }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget buildIdProofTypeDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'ID Proof Type',
        border: OutlineInputBorder(),
      ),
      items:
          [
            'Aadhaar Card',
            'PAN Card',
            'Driving License',
            'Voter ID',
            'Passport',
          ].map((type) {
            return DropdownMenuItem(value: type, child: Text(type));
          }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget buildCourseTypeDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Course Type *',
        border: OutlineInputBorder(),
      ),
      items: ['2-Wheeler', '4-Wheeler', 'Both'].map((course) {
        return DropdownMenuItem(value: course, child: Text(course));
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Course type is required' : null,
    );
  }

  static Widget buildLicenseTypeDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'License Type',
        border: OutlineInputBorder(),
      ),
      items: ['LMV', 'MCWG', 'LMV-TR', 'MCWOG'].map((license) {
        return DropdownMenuItem(value: license, child: Text(license));
      }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget buildBatchTimingDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Batch Timing',
        border: OutlineInputBorder(),
      ),
      items:
          [
            '7:00 AM - 8:00 AM',
            '8:00 AM - 9:00 AM',
            '5:00 PM - 6:00 PM',
            '6:00 PM - 7:00 PM',
          ].map((batch) {
            return DropdownMenuItem(value: batch, child: Text(batch));
          }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget buildPaymentModeDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Payment Mode',
        border: OutlineInputBorder(),
      ),
      items: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Other'].map((mode) {
        return DropdownMenuItem(value: mode, child: Text(mode));
      }).toList(),
      onChanged: onChanged,
    );
  }

  static Widget buildPaymentStatusDropdown({
    required String? value,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: const InputDecoration(
        labelText: 'Payment Status',
        border: OutlineInputBorder(),
      ),
      items: ['Pending', 'Partially Paid', 'Fully Paid'].map((status) {
        return DropdownMenuItem(value: status, child: Text(status));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Other Fields
  static Widget buildIdProofNumberField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'ID Proof Number',
        prefixIcon: Icon(Icons.credit_card),
        border: OutlineInputBorder(),
      ),
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildFeesAmountField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Course Fees (₹) *',
        prefixIcon: Icon(Icons.currency_rupee),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: Validators.validateAmount,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildEmergencyContactNameField(
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Emergency Contact Person',
        prefixIcon: Icon(Icons.contact_emergency),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildEmergencyContactPhoneField(
    TextEditingController controller,
  ) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Emergency Phone',
        prefixIcon: Icon(Icons.phone_in_talk),
        border: OutlineInputBorder(),
        counterText: '',
      ),
      keyboardType: TextInputType.phone,
      maxLength: 10,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildVehicleNumberField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Vehicle Number (if any)',
        prefixIcon: Icon(Icons.directions_car),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.characters,
      textInputAction: TextInputAction.next,
    );
  }

  static Widget buildRemarksField(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Remarks / Notes',
        prefixIcon: Icon(Icons.note),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.done,
    );
  }

  // Section Headers
  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }
}
