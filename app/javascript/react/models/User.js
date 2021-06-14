export default class User {
  constructor(attributes) {
    this.address = attributes.address;
    this.lastName = attributes.lastName;
    this.firstName = attributes.firstName;
    this.email = attributes.email;
    this.birthDate = attributes.birthDate;
    this.city = attributes.city;
    this.postalCode = attributes.postalCode;
    this.affiliationNumber = attributes.affiliationNumber;
    this.phoneNumber = attributes.phoneNumber;
  }

  fullAddress() {
    return `${this.address} - ${this.postalCode} - ${this.city}`;
  }
}
