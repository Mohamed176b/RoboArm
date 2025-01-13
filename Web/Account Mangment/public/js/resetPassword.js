import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const supabase = createClient('https://xditbsgzrqnyqrlrxset.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhkaXRic2d6cnFueXFybHJ4c2V0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDgxOTI3NjcsImV4cCI6MjAyMzc2ODc2N30.uwQA5-Bt4T7Jv5QtjSdkvnOiCIesePoumYEGU3bUv64');

const emailInput = document.getElementById("email");
const passwordForm = document.getElementById('passwordForm');
const newPasswordInput = document.getElementById('newPassword');
const confirmPasswordInput = document.getElementById('confirmPassword');
const errorMsg = document.getElementById('error-msg');

passwordForm.addEventListener('submit', async function (event) {
    event.preventDefault();
    if (validatePassword()) {
        errorMsg.textContent = '';
        try {
            const { data, error } = await supabase.auth.updateUser({
                email: emailInput.value,
                password: newPasswordInput.value
            });
            window.location.href = "updateChanged.html";
        } catch (error) {
            errorMsg.textContent = 'An error has occurred, please try again!';
        }
    }
});

function validatePassword() {
    const newPassword = newPasswordInput.value;
    const confirmPassword = confirmPasswordInput.value;
    const email = emailInput.value;

    if (newPassword.length < 8) {
        errorMsg.textContent = 'Password must be at least 8 characters long and contain at least one lowercase letter, one uppercase letter, one digit, and one special character';
        return false;
    }

    if (newPassword !== confirmPassword) {
        errorMsg.textContent = 'Passwords do not match';
        return false;
    }
    if (email == "") {
        errorMsg.textContent = 'Email filed is empty';
        return false;
    }

    return true;
}
