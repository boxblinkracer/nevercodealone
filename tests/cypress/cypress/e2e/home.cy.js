describe('Test Apache', () => {

    it('Apache2 Default Page exists', () => {
        cy.visit('/');
        cy.contains('This is the default welcome page');
    })

})